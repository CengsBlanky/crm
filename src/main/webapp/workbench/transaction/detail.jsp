<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="com.zengshuai.crm.workbench.domain.Transaction" %>
<%@ page import="com.zengshuai.crm.settings.domain.DicValue" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";

    List<DicValue> stageList = (List<DicValue>) application.getAttribute("stageList");
    Map<String, String> spMap = (Map<String, String>) application.getAttribute("spMap");
    //第一个失效状态的下标
    int seperator = 0;
    for (int i = 0; i < stageList.size(); i++) {
        String stage = stageList.get(i).getText();
        String possibility = spMap.get(stage);
        if ("0".equals(possibility)) {
            seperator = i;
            break;
        }
    }

    //获取当前stage值
    Transaction transaction = (Transaction) request.getAttribute("transactionInfo");
    String currentStage = transaction.getStage();
    //当前stage对应的possibility
    String possibility = spMap.get(currentStage);


%>
<!DOCTYPE html>
<html>
<head>
    <base href="<%=basePath%>">
    <meta charset="UTF-8">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>

    <style type="text/css">
        .mystage {
            font-size: 20px;
            vertical-align: middle;
            cursor: pointer;
        }

        .closingDate {
            font-size: 15px;
            cursor: pointer;
            vertical-align: middle;
        }
    </style>

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

    <script type="text/javascript">

        //默认情况下取消和保存按钮是隐藏的
        var cancelAndSaveBtnDefault = true;

        $(function () {
            $("#remark").focus(function () {
                if (cancelAndSaveBtnDefault) {
                    //设置remarkDiv的高度为130px
                    $("#remarkDiv").css("height", "130px");
                    //显示
                    $("#cancelAndSaveBtn").show("2000");
                    cancelAndSaveBtnDefault = false;
                }
            });

            $("#cancelBtn").click(function () {
                //显示
                $("#cancelAndSaveBtn").hide();
                //设置remarkDiv的高度为130px
                $("#remarkDiv").css("height", "90px");
                cancelAndSaveBtnDefault = true;
            });

            $(".remarkDiv").mouseover(function () {
                $(this).children("div").children("div").show();
            });

            $(".remarkDiv").mouseout(function () {
                $(this).children("div").children("div").hide();
            });

            $(".myHref").mouseover(function () {
                $(this).children("span").css("color", "red");
            });

            $(".myHref").mouseout(function () {
                $(this).children("span").css("color", "#E6E6E6");
            });


            //阶段提示框
            $(".mystage").popover({
                trigger: 'manual',
                placement: 'bottom',
                html: 'true',
                animation: false
            }).on("mouseenter", function () {
                var _this = this;
                $(this).popover("show");
                $(this).siblings(".popover").on("mouseleave", function () {
                    $(_this).popover('hide');
                });
            }).on("mouseleave", function () {
                var _this = this;
                setTimeout(function () {
                    if (!$(".popover:hover").length) {
                        $(_this).popover("hide")
                    }
                }, 100);
            });

            //刷新阶段历史
            flashHistory();


        });

        function flashHistory() {
            var tranId = "${transactionInfo.id}";
            $.ajax({
                url: "workbench/transaction/findHistoryByTranId.do",
                data: {"tranId": tranId},
                type: "get",
                dataType: "json",
                success: function (hList) {
                    var html = "";
                    $.each(hList, function (i, h) {
                        html += '<tr>';
                        html += '<td>' + h.stage + '</td>';
                        html += '<td>' + h.money + '</td>';
                        html += '<td>' + h.possibility + '</td>';
                        html += '<td>' + h.expectedDate + '</td>';
                        html += '<td>' + h.createTime + '</td>';
                        html += '<td>' + h.createBy + '</td>';
                        html += '</tr>';
                    });
                    $("#historyList").html(html);
                }
            });
        }

        function changeStage(id, stage) {
            //阶段stage.possibility,editBy(name),新的交易历史记录
            $.ajax({
                url:"workbench/transaction/changeStage.do",
                data:{
                    "stage":stage,
                    "tranId":"${transactionInfo.id}"
                },
                type:"post",
                dataType:"json",
                success:function (data) {
                    if(data.success){
                        $("#update-stage").html(data.tran.stage);
                        $("#update-possibility").html(data.tran.possibility);
                        $("#update-editBy").html(data.tran.editBy);
                        $("#update-editTime").html(data.tran.editTime);
                        flashHistory();
                        changeIcon(id,stage);
                    }else{
                        alert("阶段转换失败")
                    }
                }
            });
        }

        function changeIcon(id, stage) {
            //当前阶段的下标
            var currentId = id;
            //当前阶段
            var currentStage = stage;
            //当前阶段的possibility
            var possibility = $("#update-possibility").html();
            //seperator
            var seperator = "<%=seperator%>";
            //总图标个数
            var count = "<%=stageList.size()%>";
            if("0"==possibility){
                //seperator之前都是灰色圆圈
                for(var i = 0; i < seperator; i++){
                    $("#"+i).removeClass();
                    $("#"+i).addClass("glyphicon glyphicon-record mystage");
                    $("#"+i).css("color","#505050");
                }
                for(var i = seperator; i < count;i++){
                    if(currentId==i){
                        //红色×
                        $("#"+i).removeClass();
                        $("#"+i).addClass("glyphicon glyphicon-remove mystage");
                        $("#"+i).css("color","#FF0000");
                    }else{
                        //黑色×
                        $("#"+i).removeClass();
                        $("#"+i).addClass("glyphicon glyphicon-remove mystage");
                        $("#"+i).css("color","#505050");
                    }
                }
            }else{
                for(var i =0 ; i < currentId; i++){
                    //绿色圈
                    $("#"+i).removeClass();
                    $("#"+i).addClass("glyphicon glyphicon-ok-circle mystage");
                    $("#"+i).css("color","#90F790");
                }
                $("#"+currentId).removeClass();
                $("#"+currentId).addClass("glyphicon glyphicon-map-marker mystage");
                $("#"+currentId).css("color","#90F790");
                for(var i = parseInt(currentId)+1; i < seperator; i++){
                    //灰色圈
                    $("#"+i).removeClass();
                    $("#"+i).addClass("glyphicon glyphicon-record mystage");
                    $("#"+i).css("color","#505050");
                }
                for(var i = seperator;i < count; i++){
                    //灰色×
                    $("#"+i).removeClass();
                    $("#"+i).addClass("glyphicon glyphicon-remove mystage");
                    $("#"+i).css("color","#505050");
                }
            }
        }

    </script>

</head>
<body>

<!-- 返回按钮 -->
<div style="position: relative; top: 35px; left: 10px;">
    <a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left"
                                                                         style="font-size: 20px; color: #DDDDDD"></span></a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3>${transactionInfo.name}
            <small>${transactionInfo.money}</small>
        </h3>
    </div>
    <div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
        <button type="button" class="btn btn-default" onclick="window.location.href='edit.html';"><span
                class="glyphicon glyphicon-edit"></span> 编辑
        </button>
        <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
    </div>
</div>

<!-- 阶段状态 -->
<div style="position: relative; left: 40px; top: -50px;">
    阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <%

        if ("0".equals(possibility)) {
            //如果在后面两个阶段，说明交易失效，seperator前的图标全部为黑色圆圈,后面的阶段需要重新判断
            for (int i = 0; i < seperator; i++) {
    %>
    <span class="glyphicon glyphicon-record mystage" id="<%=i%>" onclick="changeStage('<%=i%>','<%=stageList.get(i).getText()%>')" data-toggle="popover" data-placement="bottom"
          data-content="<%=stageList.get(i).getText()%>" style="color: #505050;"></span>-------------
    <%
        }
        for (int i = seperator; i < stageList.size(); i++) {
            String stage = stageList.get(i).getText();
            if (stage.equals(currentStage)) {
                //红色×
    %>
    <span class="glyphicon glyphicon-remove mystage" id="<%=i%>" onclick="changeStage('<%=i%>','<%=stageList.get(i).getText()%>')" data-toggle="popover" data-placement="bottom"
          data-content="<%=currentStage%>" style="color: #FF0000;"></span>-------------
    <%
    } else {
        //黑色×
    %>
    <span class="glyphicon glyphicon-remove mystage" id="<%=i%>" onclick="changeStage('<%=i%>','<%=stageList.get(i).getText()%>')" data-toggle="popover" data-placement="bottom"
          data-content="<%=stageList.get(i).getText()%>" style="color: #505050;"></span>-------------
    <%
            }
        }

    } else {
        //当前图标为选中图标，之前的图标为绿色圈，当前图标之后，分隔符之后的为灰色圈
        int index = 0;
        for (int i = 0; i < seperator; i++) {
            if (currentStage.equals(stageList.get(i).getText())) {
                //获取当前阶段对应的下标
                index = i;
            }
        }
        //在当前阶段之前的，为绿色圆圈
        for (int i = 0; i < index; i++) {
    %>
    <span class="glyphicon glyphicon-ok-circle mystage" id="<%=i%>" onclick="changeStage('<%=i%>','<%=stageList.get(i).getText()%>')" data-toggle="popover" data-placement="bottom"
          data-content="<%=stageList.get(i).getText()%>" style="color: #90F790;"></span>-------------
    <%
        }
        //当前阶段为被选中图标
    %>
    <span class="glyphicon glyphicon-map-marker mystage" id="<%=index%>" onclick="changeStage('<%=index%>','<%=stageList.get(index).getText()%>')" data-toggle="popover" data-placement="bottom"
          data-content="<%=currentStage%>" style="color: #90F790;"></span>-------------
    <%
        //当前阶段之后为灰色圆圈
        for (int i = index + 1; i < seperator; i++) {
    %>
    <span class="glyphicon glyphicon-record mystage" id="<%=i%>" onclick="changeStage('<%=i%>','<%=stageList.get(i).getText()%>')" data-toggle="popover" data-placement="bottom"
          data-content="<%=stageList.get(i).getText()%>" style="color: #505050;"></span>-------------
    <%
            }

        }
        //说明交易没有失效,分隔符之后的图标全部为黑色×
        for (int i = seperator; i < stageList.size(); i++) {
    %>
    <span class="glyphicon glyphicon-remove mystage" id="<%=i%>" onclick="changeStage('<%=i%>','<%=stageList.get(i).getText()%>')" data-toggle="popover" data-placement="bottom"
          data-content="<%=stageList.get(i).getText()%>" style="color: #505050;"></span>

    <%
            if(i < stageList.size() - 1){
    %>
    -------------
    <%
            }
        }
    %>
    <span class="closingDate">${transactionInfo.expectedDate}</span>
</div>

<!-- 详细信息 -->
<div style="position: relative; top: 0px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${transactionInfo.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${transactionInfo.money}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>${transactionInfo.customerId}-${transactionInfo.name}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${transactionInfo.expectedDate}</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">客户名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${transactionInfo.customerId}</b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="update-stage">${transactionInfo.stage}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">类型</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${transactionInfo.type}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="update-possibility">${transactionInfo.possibility}</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">来源</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${transactionInfo.source}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${transactionInfo.activityId}</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">联系人名称</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${transactionInfo.contactsId}</b>
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${transactionInfo.createBy}&nbsp;&nbsp;</b>
            <small style="font-size: 10px; color: gray;">${transactionInfo.createTime}</small>
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b id="update-editBy">${transactionInfo.editBy}&nbsp;&nbsp;</b>
            <small style="font-size: 10px; color: gray;" id="update-editTime">${transactionInfo.editTime}</small>
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 80px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${transactionInfo.description}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 90px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${transactionInfo.contactSummary}&nbsp;
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 100px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${transactionInfo.nextContactTime}&nbsp;</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div style="position: relative; top: 100px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <!-- 备注1 -->
    <div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>哎呦！</h5>
            <font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b>
            <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>

    <!-- 备注2 -->
    <div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>呵呵！</h5>
            <font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b>
            <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>

    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"
                      placeholder="添加备注..."></textarea>
            <p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
                <button id="cancelBtn" type="button" class="btn btn-default">取消</button>
                <button type="button" class="btn btn-primary">保存</button>
            </p>
        </form>
    </div>
</div>

<!-- 阶段历史 -->
<div>
    <div style="position: relative; top: 100px; left: 40px;">
        <div class="page-header">
            <h4>阶段历史</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table id="activityTable" class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>阶段</td>
                    <td>金额</td>
                    <td>可能性</td>
                    <td>预计成交日期</td>
                    <td>创建时间</td>
                    <td>创建人</td>
                </tr>
                </thead>
                <tbody id="historyList">
                <%--<tr>
                    <td>资质审查</td>
                    <td>5,000</td>
                    <td>10</td>
                    <td>2017-02-07</td>
                    <td>2016-10-10 10:10:10</td>
                    <td>zhangsan</td>
                </tr>--%>

                </tbody>
            </table>
        </div>

    </div>
</div>

<div style="height: 200px;"></div>

</body>
</html>