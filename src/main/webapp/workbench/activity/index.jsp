<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
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
<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>


	<script type="text/javascript">
	$(function () {
		$(".time").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-left"
		});



	$("#saveActivityBtn").click(function () {
		$.ajax({
			url:"workbench/activity/saveActivity.do",
			data:{
				"owner":$.trim($("#create-marketActivityOwner").val()),
				"name":$.trim($("#create-marketActivityName").val()),
				"startDate":$.trim($("#create-startTime").val()),
				"endDate":$.trim($("#create-endTime").val()),
				"cost":$.trim($("#create-cost").val()),
				"description":$.trim($("#create-describe").val())
			},
			type:"post",
			dataType:"json",
			success:function (flag) {
				if(flag.success){
					$("form")[0].reset();
					displayAList(1,2);
					$("#createActivityModal").modal("hide");
				}else{
					alert("数据保存失败！")
				}
			}

		})
	});



		$("#createModalBtn").click(function () {
			$.ajax({
				url:"workbench/activity/findUsers.do",
				type:"get",
				dataType:"json",
				success:function (uList) {
					var html = "<option>-请选择-</option>";
					$.each(uList,function (i,n) {
						html += "<option value='"+n.id+"'>"+n.name+"</option>";
					});
					$("#create-marketActivityOwner").html(html);
					//默认所有者姓名为当前用户姓名
					var id = "${userInfo.id}";
					$("#create-marketActivityOwner").val(id);

					$("#createActivityModal").modal("show");
				}
			});
		});

		//为查询按钮绑定查询
		$("#searchActivityBtn").click(function () {
			//将参数的值存储在隐藏域中，发送ajax请求的时候，也是从隐藏域中取值，如果没有点击查询按钮就刷新列表，那么还是发送隐藏域中的值作为参数查询，不会出现不点击查询按钮却执行了不同参数的查询
			$("#hidden-name").val($("#activity-name").val());
			$("#hidden-owner").val($("#activity-owner").val());
			$("#hidden-startDate").val($("#startTime").val());
			$("#hidden-endDate").val($("#endTime").val());
			displayAList(1,2);
		});


		//绑定全选按钮
		$(":checkbox[name='mainbox']").click(function () {
			$(":checkbox[name='singlebox']").prop("checked",this.checked);
		});
		//绑定单选按钮
		$("#showActivity").on("click",$(":checkbox[name='singlebox']"),function () {
			$(":checkbox[name='mainbox']").prop("checked",$(":checkbox[name='singlebox']").length==$(":checkbox[name='singlebox']:checked").length);
		});


		//点击修改，绑定修改按钮
		$("#activityUpdateBtn").click(function () {
			//需要获取的数据：所有者的姓名（user.name）,将姓名填在下拉框中
			//活动（activity）,所有的信息（名称，开始日期，结束日期，成本，描述）
			//一次只能修改一个活动信息，所有加以限定
			var chosenActivityNum = $(":checkbox[name=singlebox]:checked").length;
			if(chosenActivityNum == 0){
				alert("请选择需要修改的活动！");
			}else if(chosenActivityNum > 1){
				alert("一次只能修改一个活动！");
			}else{
				var activityId = $(":checkbox[name=singlebox]:checked").val();
				$.ajax({
					url:"workbench/activity/findUsersAndActivities.do",
					data:{"activityId":activityId},
					type:"post",
					dataType:"json",
					success:function (data) {
						var html = "";
						$.each(data.uList,function (i,user) {
							html += "<option value='"+user.id+"'>"+user.name+"</option>"
						});
						$("#edit-marketActivityOwner").html(html);
						//默认显示对应拥有者的姓名
						var id = data.activity.owner;
						$("#edit-marketActivityOwner").val(id);

						$("#edit-marketActivityName").val(data.activity.name);
						$("#edit-startTime").val(data.activity.startDate);
						$("#edit-endTime").val(data.activity.endDate);
						$("#edit-cost").val(data.activity.cost);
						$("#edit-describe").val(data.activity.description);
					}
			});
				//获取数据之后打开模态窗口
				$("#editActivityModal").modal("show");
			}


		});

		//绑定更新按钮
		$("#updateActivity").click(function () {
			//发送异步请求，将修改模态窗口的数据发送至后端
			$.ajax({
				url:"workbench/activity/updateActivity.do",
				data:{
					"editBy":"${userInfo.name}",
					"id":$(":checkbox[name='singlebox']:checked").val(),
					"owner":$("#edit-marketActivityOwner").val(),
					"name":$.trim($("#edit-marketActivityName").val()),
					"startDate":$("#edit-startTime").val(),
					"endDate":$("#edit-endTime").val(),
					"cost":$.trim($("#edit-cost").val()),
					"description":$.trim($("#edit-describe").val())
				},
				type:"post",
				dataType:"json",
				success:function (flag) {
					if(flag.success){
						//关闭模态窗口
						$("#editActivityModal").modal("hide");
						//保持页面不变
						displayAList($("#activityPage").bs_pagination('getOption', 'currentPage')
								,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
					}else{
						alert("活动修改失败！")
					}
				}
			});
		});



		//绑定删除按钮
		$("#deleteActivityBtn").click(function () {
			//获取被选中的活动的id，id可能有多个
			var $checkedbox = $(":checkbox[name='singlebox']:checked");
			if($checkedbox.length==0){
				alert("请选择需要删除的活动。");
			}else{
				if(confirm("确定要删除选定的活动吗？")){
					var ids = "";
					for(var i=0;i<$checkedbox.length;i++){
						ids +="id=" + $checkedbox[i].value;
						if(i < $checkedbox.length - 1){
							ids += "&";
						}
					}
					$.ajax({
						url:"workbench/activity/deleteActivity.do",
						data:ids,
						type:"get",
						dataType:"json",
						success:function (flag) {
							if(flag.success){
								//删除成功，列表应当回到第一页并保持每页的记录数量
								displayAList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
							}else{
								alert("删除失败");
							}
						}
					});
				}
			}

		});





		//在页面加载完毕之后再活动列表中显示活动
		displayAList(1,3);

		function displayAList(pageNo,pageSize) {

			//查询之前从隐藏域中取值
			$("#activity-name").val($("#hidden-name").val());
			$("#activity-owner").val($("#hidden-owner").val());
			$("#startTime").val($("#hidden-startDate").val());
			$("#endTime").val($("#hidden-endDate").val());
			$.ajax({
				url:"workbench/activity/showActivityList.do",
				data:{
					"pageNo":pageNo,
					"pageSize":pageSize,
					"name":$.trim($("#activity-name").val()),
					"owner":$.trim($("#activity-owner").val()),
					"startDate":$("#startTime").val(),
					"endDate":$("#endTime").val()
				},
				type:"get",
				dataType:"json",
				success:function (data) {
					var html = "";
					$.each(data.dataList,function (i, data) {
						html += "<tr class=\"active\">" +
								"<td><input type=\"checkbox\" name='singlebox' value='"+data.id+"'/></td>" +
								"<td><a href='javascript:void(0)' style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/activity/detailDisplay.do?activityId="+data.id+"';\">"+data.name+"</a></td>" +
								"<td>"+data.owner+"</td>" +
								"<td>"+data.startDate+"</td>" +
								"<td>"+data.endDate+"</td>" +
								"</tr>";
					});
					$("#showActivity").html(html);

					var totalPages = data.totalRecord%pageSize==0?data.totalRecord/pageSize:parseInt(data.totalRecord/pageSize)+1;
					/*引入分页插件*/
					$("#activityPage").bs_pagination({
						currentPage: pageNo, // 页码
						rowsPerPage: pageSize, // 每页显示的记录条数
						maxRowsPerPage: 20, // 每页最多显示的记录条数
						totalPages: totalPages, // 总页数
						totalRows: data.totalRecord, // 总记录条数

						visiblePageLinks: 3, // 显示几个卡片

						showGoToPage: true,
						showRowsPerPage: true,
						showRowsInfo: true,
						showRowsDefaultInfo: true,

						onChangePage : function(event, data){
							displayAList(data.currentPage , data.rowsPerPage);
						}
					});



				}
			});
		}
	})

	
</script>
</head>
<body>

	<%--隐藏的查询域--%>
	<input type="hidden" id="hidden-name">
	<input type="hidden" id="hidden-owner">
	<input type="hidden" id="hidden-startDate">
	<input type="hidden" id="hidden-endDate">

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label" >所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">

								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-startTime" readonly>
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-endTime" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveActivityBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">

								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" >
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startTime" readonly />
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-endTime" readonly />
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateActivity">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	<%------------------------------------------------查找活动列表-----------------------------------------------------%>
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 5px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 0px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="activity-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="activity-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon" >开始日期</div>
					  <input class="form-control time" type="text" id="startTime" readonly />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon" >结束日期</div>
					  <input class="form-control time" type="text" id="endTime" readonly />
				    </div>
				  </div>
				  <button type="button" id="searchActivityBtn" class="btn btn-default">查询</button>
				  
				</form>
			</div>

			<%--------------------------------------------增删改活动的按钮---------------------------------------------------------%>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createModalBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" data-toggle="modal" id="activityUpdateBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteActivityBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>

			</div>
			<%---------------------------------------------------活动列表----------------------------------------------------%>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" name="mainbox" /></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="showActivity">

					</tbody>
				</table>
			</div>
			<%---------------------------------------------------分页页面----------------------------------------------------%>
			<div style="height: 50px; position: relative;top: 30px;">
				<div id="activityPage"></div>
			</div>
</body>
</html>