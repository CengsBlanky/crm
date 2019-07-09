<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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

	$(function(){
		showTranList(1,2);

		//绑定查询按钮
		$("#searchBtn").click(function () {
			//给隐藏域赋值
			$("#hide-owner").val($("#find-owner").val());
			$("#hide-name").val($("#find-name").val());
			$("#hide-customerName").val($("#find-customerName").val());
			$("#hide-tranStage").val($("#find-tranStage").val());
			$("#hide-tranType").val($("#find-tranType").val());
			$("#hide-tranSrc").val($("#find-tranSrc").val());
			$("#hide-contactName").val($("#find-contactName").val());
			showTranList(1,2);
		});


		//为创建按钮绑定事件





	});

	function showTranList(pageNo,pageSize){
		//从隐藏域中取值
		$("#find-owner").val($("#hide-owner").val());
		$("#find-name").val($("#hide-name").val());
		$("#find-customerName").val($("#hide-customerName").val());
		$("#find-tranStage").val($("#hide-tranStage").val());
		$("#find-tranType").val($("#hide-tranType").val());
		$("#find-tranSrc").val($("#hide-tranSrc").val());
		$("#find-contactName").val($("#hide-contactName").val());

		$.ajax({
			url:"workbench/transaction/showTranList.do",
			data:{
				"pageNo":pageNo,
				"pageSize":pageSize,
				"owner":$("#find-owner").val(),
				"name":$("#find-name").val(),
				"customerName":$("#find-customerName").val(),
				"tranStage":$("#find-tranStage").val(),
				"tranType":$("#find-tranType").val(),
				"tranSrc":$("#find-tranSrc").val(),
				"contactName":$("#find-contactName").val()
			},
			type:"get",
			dataType:"json",
			success:function (data) {//totalRecord,dataList
				var html = "";
				$.each(data.dataList,function (i, transaction) {
					html += '<tr>';
					html += '<td><input type="checkbox" id="'+transaction.id+'" name="mainbox" /></td>';
					html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/transaction/detail.do?id='+transaction.id+'\';">'+transaction.name+'</a></td>';
					html += '<td>'+transaction.customerId+'</td>';
					html += '<td>'+transaction.stage+'</td>';
					html += '<td>'+transaction.type+'</td>';
					html += '<td>'+transaction.owner+'</td>';
					html += '<td>'+transaction.source+'</td>';
					html += '<td>'+transaction.contactsId+'</td>';
					html += '</tr>';
				});
				$("#showTranList").html(html);
				var totalPages = data.totalRecord%pageSize==0?data.totalRecord/pageSize:parseInt(data.totalRecord/pageSize)+1;
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
						showTranList(data.currentPage , data.rowsPerPage);
					}
				});
			}

		});
	}
	
</script>
</head>
<body>
<input type="hidden" id="hide-owner" />
<input type="hidden" id="hide-name" />
<input type="hidden" id="hide-customerName" />
<input type="hidden" id="hide-tranStage" />
<input type="hidden" id="hide-tranType" />
<input type="hidden" id="hide-tranSrc" />
<input type="hidden" id="hide-contactName" />

	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>交易列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="find-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="find-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="find-customerName">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">阶段</div>
					  <select class="form-control" id="find-tranStage">
					  	<option value="">-请选择-</option>
					  	<c:forEach items="${stageList}" var="stage">
							<option value="${stage.value}">${stage.text}</option>
						</c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">类型</div>
					  <select class="form-control" id="find-tranType">
					  	<option value="">-请选择-</option>
					  	<c:forEach items="${transactionTypeList}" var="type">
							<option value="${type.value}">${type.text}</option>
						</c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="find-tranSrc">
						  <option value="">-请选择-</option>
						  <c:forEach items="${sourceList}" var="src">
							  <option value="${src.value}">${src.text}</option>
						  </c:forEach>
						</select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">联系人名称</div>
				      <input class="form-control" type="text" id="find-contactName">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" onclick="window.location.href='workbench/transaction/findOwner.do';"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" onclick="window.location.href='workbench/transaction/edit.jsp';"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" /></td>
							<td>名称</td>
							<td>客户名称</td>
							<td>阶段</td>
							<td>类型</td>
							<td>所有者</td>
							<td>来源</td>
							<td>联系人名称</td>
						</tr>
					</thead>
					<tbody id="showTranList">
						<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">动力节点-交易01</a></td>
							<td>动力节点</td>
							<td>谈判/复审</td>
							<td>新业务</td>
							<td>zhangsan</td>
							<td>广告</td>
							<td>李四</td>
						</tr>
					</tbody>
				</table>
			</div>
			<%------------------------------------分页控件------------------------------------------%>
			<div style="height: 50px; position: relative;top: 20px;" id="activityPage">

			</div>
			
		</div>
		
	</div>
</body>
</html>