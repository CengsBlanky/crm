<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";

	Map<String,String> spMap = (Map<String,String>)application.getAttribute("spMap");
	Set<String> set = spMap.keySet();
%>

<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
	<script>
		var json = {
			<%for(String key:set){
				String value = spMap.get(key);
			%>
			"<%=key%>":<%=value%>,
			<%
			}
			%>
		};


		$(function () {
			$("#create-customerName").typeahead({
				source: function (query, process) {
					$.get(
							"workbench/transaction/getCustomerName.do",
							{ "name" : query },
							function (data) {
								//alert(data);

								/*

                                    data是我们为自动补全插件提供的数据
                                    [String，String，String]
                                    [{客户名称1},{2},{3}]

                                 */

								//该方法由插件提供，拿着我们提供的data，用来做值得动画展现
								//注意：该方法只识别字符串数组
								process(data);
							},
							"json"
					);
				},
				delay: 800
			});

			$("#create-transactionStage").change(function () {
				//取得阶段下拉框的内容
				var stage = $("#create-transactionStage").val();
				//给可能性文本框赋值
				$("#create-possibility").val(json[stage]);
			});

			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});

			$(".next-time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "top-left"
			});

			//点击市场活动源的查找按钮，进行市场活动查找
			$("#find-actitivyBtn").click(function () {
				//获取文本框中的市场活动名称
				var activityName = $("#activityName").val();
				//发送异步请求对象，模糊查找活动
				$.ajax({
					url:"workbench/transaction/findActivityByName.do",
					data:{"activityName":activityName},
					type:"get",
					dataType:"json",
					success:function (aList) {
						var html="";
						$.each(aList,function (i,a) {
							html += '<tr>';
							html += '<td><input type="radio" name="activitybox" value="'+a.id+'" /></td>';
							html += '<td id="n'+a.id+'">'+a.name+'</td>';
							html += '<td>'+a.startDate+'</td>';
							html += '<td>'+a.endDate+'</td>';
							html += '<td>'+a.owner+'</td>';
							html += '</tr>';
						});
						$("#activityList").html(html);
					}
				});
			});
			//市场活动提交按钮绑定点击事件
			$("#selectActivityBtn").click(function () {
				//做两件事：将市场活动名称显示在文本框中；将市场活动id放入隐藏域中
				var activityId = $("input[name='activitybox']:checked").val();
				$("#create-activitySrc").val($("#n"+activityId).html());
				$("#create-activityId").val(activityId);
				//关闭模态窗口
				$("#findMarketActivity").modal("hide");
				//清空窗口内容,清空列表
				$("#activityName").val("");
				$("#activityList").empty();
			});

			//点击联系人查找按钮，显示联系人列表
			$("#find-contactNameBtn").click(function () {
				//发送ajax请求，模糊查找联系人姓名
				$.ajax({
					url:"workbench/transaction/searchContactByName.do",
					data:{"fullname":$("#find-contactName").val()},
					type:"get",
					dataType:"json",
					success:function (cList) {
						var html = "";
						$.each(cList,function (i, contact) {
							html += '<tr>';
							html += '<td><input type="radio" name="contactbox" value="'+contact.id+'"/></td>';
							html += '<td id="n'+contact.id+'">'+contact.fullname+'</td>';
							html += '<td>'+contact.email+'</td>';
							html += '<td>'+contact.mphone+'</td>';
							html += '</tr>';
						});
						$("#showContactList").html(html);
					}
				});
			});
			//联系人查找提交按钮绑定点击事件
			$("#selectContactBtn").click(function () {
				//获取联系人id，联系人姓名
				var contactId = $("input[name='contactbox']:checked").val();
				//将联系人id赋值给隐藏域
				$("#create-contactsId").val(contactId);
				//将联系人姓名放在联系人姓名文本框中
				$("#create-contactsName").val($("#n"+contactId).html())
				//关闭模态窗口
				$("#findContacts").modal("hide");
				//清空模态窗口
				$("#find-contactName").val("");
				$("#showContactList").empty();
			});



			//为保存按钮绑定事件
			$("#saveTranBtn").click(function () {
				//获取页面中的参数
				$.ajax({
					url:"workbench/transaction/saveTran.do",
					data:{
						"owner":$("#create-transactionOwner").val(),
						"money":$("#create-amountOfMoney").val(),
						"name":$("#create-transactionName").val(),
						"expectedDate":$("#create-expectedClosingDate").val(),
						//通过客户名称去查客户表，将客户id存入customerId中；或者新建一个客户
						"customerName":$("#create-customerName").val(),
						"stage":$("#create-transactionStage").val(),
						"type":$("#create-transactionType").val(),
						"source":$("#create-clueSource").val(),
						"activityId":$("#create-activityId").val(),
						"contactsId":$("#create-contactsId").val(),
						"description":$("#create-description").val(),
						"contactSummary":$("#create-contactSummary").val(),
						"nextContactTime":$("#create-nextContactTime").val()
					},
					type:"post",
					dataType:"json",
					success:function (flag) {
						if(flag.success){
							//新增成功返回至交易列表页面
							window.location.href="workbench/transaction/index.jsp";
						}else{
							alert("交易添加失败");
						}
					}
				});
			});

			//禁用回车键
			$(window).keydown(function (event) {
				if(event.keyCode==13){
					return false;
				}
			});

		});



	</script>

</head>
<body>

	<!-- 查找市场活动 -->	
	<div class="modal fade" id="findMarketActivity" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" autocomplete="off" id="activityName" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
							&nbsp;&nbsp;&nbsp;&nbsp;<button type="button" class="btn btn-default" id="find-actitivyBtn">查找</button>
						</form>
					</div>
					<table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
							</tr>
						</thead>
						<tbody id="activityList">
							<%--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>--%>

						</tbody>
					</table>
					<div style="position: relative; left: 90%;">
						<button type="button" class="btn btn-default" id="selectActivityBtn">提交</button>
					</div>
				</div>
			</div>
		</div>
	</div>

	<!----------------------------------------------- 查找联系人 ----------------------------------------------->
	<div class="modal fade" id="findContacts" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找联系人</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" autocomplete="off" id="find-contactName" class="form-control" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
							&nbsp;&nbsp;&nbsp;&nbsp;<button type="button" class="btn btn-default" id="find-contactNameBtn">查找</button>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>邮箱</td>
								<td>手机</td>
							</tr>
						</thead>
						<tbody id="showContactList">
							<%--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>李四</td>
								<td>lisi@bjpowernode.com</td>
								<td>12345678901</td>
							</tr>--%>

						</tbody>
					</table>
					<div style="position: relative; left: 90%;">
						<button type="button" class="btn btn-default" id="selectContactBtn">提交</button>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	<%--------------------------------------------------创建交易---------------------------------------------------%>
	<div style="position:  relative; left: 30px;">
		<h3>创建交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="saveTranBtn">保存</button>
			<button type="button" class="btn btn-default">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form class="form-horizontal" role="form" style="position: relative; top: -30px;">
		<div class="form-group">
			<label for="create-transactionOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionOwner">
					<c:forEach items="${uList}" var="user">
						<option value="${user.id}" ${userInfo.id eq user.id?"selected":""}>${user.name}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-amountOfMoney" class="col-sm-2 control-label">金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-amountOfMoney">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-transactionName">
			</div>
			<label for="create-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time" id="create-expectedClosingDate" readonly />
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-customerName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" autocomplete="off" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
			</div>
			<label for="create-transactionStage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="create-transactionStage">
			  	<option>-请选择-</option>
			  	<c:forEach items="${stageList}" var="stage">
					<option value="${stage.value}">${stage.text}</option>
				</c:forEach>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionType" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionType">
				  <option value="">-请选择-</option>
				  <c:forEach items="${transactionTypeList}" var="type">
					  <option value="${type.value}">${type.text}</option>
				  </c:forEach>
				</select>
			</div>
			<label for="create-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-possibility">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-clueSource" class="col-sm-2 control-label">来源</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-clueSource">
				  <option value="">-请选择-</option>
				  <c:forEach items="${sourceList}" var="source">
					  <option value="${source.value}">${source.text}</option>
				  </c:forEach>
				</select>
			</div>
			<label for="create-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" data-toggle="modal" data-target="#findMarketActivity"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-activitySrc">
				<input type="hidden" id="create-activityId">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" data-toggle="modal" data-target="#findContacts"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-contactsName">
				<input type="hidden" id="create-contactsId">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-description" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-description"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control next-time" id="create-nextContactTime" readonly />
			</div>
		</div>
		
	</form>
</body>
</html>