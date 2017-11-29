<%@ page language="java" pageEncoding="UTF-8"%>
<%@ include file="/base/base.jsp"%>
<!DOCTYPE html>
<html class="app js no-touch no-android no-chrome firefox no-iemobile no-ie no-ie10 no-ie11 no-ios" lang="zh-CN">
<head>
<jsp:include flush="true" page="/common/resource.jsp">
	<jsp:param name="rules" value="list,date" />
</jsp:include>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
<meta name="description" content="zeeddemo">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<title>列表</title>
	<!-- 弹出模态化窗体，需要引入下边这两个js -->
<script src="${contextPath}/js/jquery_002.js"></script>
<script src="${contextPath}/js/bootstrap.js"></script>
<script src="//cdn.bootcss.com/jqueryui/1.11.4/jquery-ui.js"></script>

</head>
<style>
@media ( min-width : 768px) {
	.vbox>header ~ section {
		top: 89px;
	}
}
.form-group{overflow:hidden;}
.datepicker.dropdown-menu{z-index:99999 !important;}
</style>
<script type="text/javascript">

//点击添加关注按钮，打开窗口
var ord_id =null;
var status =null;
var amount =null ;//订单金额
var user_id=null;
var pay_target=null;//支付目标（1：支付运费，2：支付保险费）
var pay_way =null;
var user_type_state=${user_type_state };


function addPay(id,sts,money,uid){	
	 ord_id=id;
	  status=sts;
	amount=money;//金额：运费或保险费或支付司机的运费 
	  user_id=uid;

 	  if( user_type_state!=null && user_type_state == 3){ 
 		 
/* 		后台 运费和保险费  余额支付和支付宝支付

if(status=='1'){
			 pay_target = 1;//支付目标（1：支付运费，2：支付保险费）
		
			 $("#basic_order_amount").text(amount);//显示运费金额
		  $('#myModalPay').draggable();
			$('#myModalPay').modal('show');//弹出支付运费框
		
		  }
		  if(status=='2'){
			   pay_target = 2;//支付目标（1：支付运费，2：支付保险费）
		 
			   $("#basic_insure_amount").text(amount);//显示保险金额
		  $('#myModalPayInsure').draggable();
			$('#myModalPayInsure').modal('show');//弹出支付保险费框
			
		  } */
 		  
 		
		  if(status == '5'){
			  alert('该货物还在送货中，还没有送达，请您确定是否操作该按钮');
			  $('#myModal').draggable();
				$('#myModal').modal('show');//弹出支付司机运费框
		  }	
 		 if( status == '6'){
			  $('#myModal').draggable();
				$('#myModal').modal('show');//弹出支付司机运费框 
 			  }
		}else{
			alert('您的身份不是物流公司，不可以操作该按钮');
			return;
		}	
}



//支付运费或者保险费
function addPayOrder(){
	var balance="${balance}";
 	if(status=="1"){
		pay_way=$("input[name='pd_FrpId']:checked").val();//支付类型（1：余额，2支付宝）
	}
	if(status=="2"){
		pay_way=$("input[name='alipay']:checked").val();//支付类型（1：余额，2支付宝)
	} 
	
	alert(pay_way);

	$.ajax({
    	type:"post",
    	url:'<%=basePath%>/OrderInfoAction/PayOrderMoney',
    	data:"pay_amount="+amount+"&pay_way="+pay_way+"&pay_target="+pay_target+
    		 "&order_id="+ord_id+"&user_id="+user_id+"&balance="+balance,
	     	error:function(){
			alert("操作失败！");
	     	},
	     	success:function(msg){
	     		if(msg=='210'){
	 	       		alert("请求参数不合法！");
	 	       		
	     		}else if(msg=='212'){
	 	       		alert("暂不支持在线和余额组合付款，请选择一种方式进行支付！");
	       		}else if(msg=='213'){
	       			alert("余额不足，请重新支付！");
	       		}else if(msg=='214'){	       			
	       			alert("支付金额和使用余额不匹配，请选择支付方式！");
	       		}else if(msg=='215'){	       			
	       	  		$('#myModalPay').modal('hide');//隐藏运费支付页面
	       	  		alert("支付成功！");
	 	       		$("#submitForm").submit(); //刷新列表
	       		}else if(msg=='216'){	       			
	       			alert("余额不足，请重新支付！");
	       		}else if(msg.code=='217'){	
	       			$('#myModalPayInsure').modal('hide');//隐藏保险支付页面
					document.getElementById("qr_code").innerHTML = msg.data;
					$("[name='punchout_form']").submit();//弹出支付宝二维码页面
					
					//$('.punchout_form').submit();
					//$("#qr_code").html(msg.data);
	       		 //$('#myCode').draggable();
				//	$('#myCode').modal('show');
	       		//	alert("生成订单成功！");
	       		
	       		if(msg.code == '289'){
	       			
	       			alert('支付失败');
	       		}
	 	       	//	$("#submitForm").submit(); //刷新列表
	 	       	
	       		}else if(msg=='220'){	       			
	       			alert("订单状态已被更新，请重新加载页面！");
	       		}else if(msg=='221'){	       			
	       			alert("订单不存在！");
	       		}else if(msg=='222'){	       			
	       			alert("服务器异常，请稍侯再试！");
	       		}
	       		else{
	   			alert("操作失败！");
	   		}
	     }
	});
		
		
	
	}



//提交保存支付给司机的钱
function savePay(){
	//禁用提交按钮，防重复提交
	//$("#btnSubmit").attr("disabled", "disabled");
	var pay_driver_amount = $('#pay_driver_amount').val();
	var cha = amount - pay_driver_amount;
	if(pay_driver_amount==null || pay_driver_amount==""){
		alert("提示：付给司机的运费不能为空！");
		return;
	}
	if( pay_driver_amount < 0){

		alert("提示：付给司机的运费不能为负数！");
		return;
	}
	if( cha<0 ){
		alert("提示：付给司机的运费禁止小于0或者大于订单金额！")
		return;
	}
	$.ajax({
    	type:"post",
    	url:'<%=basePath%>/OrderInfoAction/savePay',
    	data:"pay_driver_amount="+pay_driver_amount+"&order_id="+ord_id,
	     	error:function(){
			alert("操作失败！");
	     	},
	     	success:function(msg){
	     		
	     		if(msg=='100'){
	     			$('#myModal').modal('hide');
	 	       		alert("司机出发还不到20分钟，不可以操作已确认到达并支付，请稍候在试！");
	     		}else if(msg=='200'){
	 	       		$('#myModal').modal('hide');
	 	       		alert("确认支付操作成功！");
	 	       		$("#submitForm").submit(); //刷新列表
	       		}else if(msg=='300'){
	       			$('#myModal').modal('hide');
	       			alert("订单状态已被更新，请重新加载页面！");
	       		}else if(msg=='400'){	       			
	       			alert("订单不存在，请重新核对！");
	       		}else{
	   			alert("操作失败！");
	   		}
	      	}
	});
	}



</script>

<body bgcolor="#374B5E;">
	<section class="vbox">
		<header class="header bg-white b-b clearfix">
			<div class="row m-t-sm">
			<!-- 按钮区域 
				<div class="row">
					<div class="col-sm-12 m-b-xs" style="padding-left:25px;">
						<button type="button" onclick="undoOrder()" class="btn btn-primary .badge">
							<i class="glyphicon glyphicon-minus"></i>撤销订单
						</button>
						<button type="button" onclick="del()" class="btn btn-primary .badge">
							<i class="glyphicon glyphicon-minus"></i>删除
						</button>
					</div>
				</div> -->
				<div class="row">
					<div class="col-sm-12 m-b-xs" style="padding-left:25px;">
						<div class="m-t-sm">
							<button id="backbutton1" type="button" onclick="window.history.back();"
								class="btn btn-danger btn-sm input-submit">返回
							</button>
							 <button type="button" onclick="exportExcel()" class="btn btn-primary .badge">
								导出
							</button>
						</div>
					</div>
				<!-- 
					<div class="col-sm-12 m-b-xs" style="padding-left:25px;">
					<button id="backbutton1" type="button" onclick="window.history.back();"
								class="btn btn-danger btn-sm input-submit">返回
							</button>
							
							<button type="button" onclick="exportExcel();" class="btn btn-primary .badge">
							导出
							</button>
						</div> -->
				</div>
				<!-- 检索条件  -->
				<div class="row">
					<div class="col-sm-12 m-b-xs" style="padding-left:25px;">
						<form class="form-inline" id="submitForm" name="submitForm" action="<%=basePath%>/OrderInfoAction/index" method="post">
							<div class="form-group">
								<input name="order_code" value="${paraMap.order_code[0]}" style="width: 120px;" class="input-sm form-control" placeholder="订单编号" type="text" />
							</div>
							<div class="form-group">
								<input name="nickname" value="${paraMap.nickname[0]}" style="width: 120px;" class="input-sm form-control" placeholder="货主昵称" type="text" />
							</div>
							<div class="form-group">
								<input name="car_number" value="${paraMap.car_number[0]}" style="width: 120px;" class="input-sm form-control" placeholder="车牌号" type="text" />
							</div>
							<div class="form-group">
								<input name="driver_name" value="${paraMap.driver_name[0]}" style="width: 80px;" class="input-sm form-control" placeholder="司机真名" type="text" />
							</div>
							<div class="form-group">
								<input name="start_city" value="${paraMap.start_city[0]}" style="width: 80px;" class="input-sm form-control" placeholder="起始城市" type="text" />
							</div>
							<div class="form-group">
								<input name="arrive_city" value="${paraMap.arrive_city[0]}" style="width: 80px;" class="input-sm form-control" placeholder="目的城市" type="text" />
							</div>
							
							<div class="form-group">
								<input id="begin_date" name="begin_date" placeholder="起始时间" value="${paraMap.begin_date[0] }"
								class="form-control datepicker-input" style="width: 100px;cursor: pointer;"
								data-date-format="yyyy-mm-dd" data-date-autoclose=true />
							</div>
							<div class="form-group">
								<input id="end_date" name="end_date" placeholder="结束时间" value="${paraMap.end_date[0] }"
								class="form-control datepicker-input" style="width: 100px;cursor: pointer;"
								data-date-format="yyyy-mm-dd" data-date-autoclose=true />
							</div>
							<div class="form-group">
								<select class="form-control" name="order_status">
									<option value = "" <c:if test="${paraMap.order_status[0] == ''}">selected</c:if>>订单状态</option>
									<option value = "1" <c:if test="${paraMap.order_status[0] == '1'}">selected</c:if>>订单已发布</option>
									<option value = "2" <c:if test="${paraMap.order_status[0] == '2'}">selected</c:if>>订单已付款</option>
									<option value = "3" <c:if test="${paraMap.order_status[0] == '3'}">selected</c:if>>已接单</option>
									<option value = "4" <c:if test="${paraMap.order_status[0] == '4'}">selected</c:if>>取货中</option>
									<option value = "5" <c:if test="${paraMap.order_status[0] == '5'}">selected</c:if>>送货中</option>
									<option value = "6" <c:if test="${paraMap.order_status[0] == '6'}">selected</c:if>>货物已送达</option>
									<option value = "7" <c:if test="${paraMap.order_status[0] == '7'}">selected</c:if>>已确认收货</option>
									<option value = "8" <c:if test="${paraMap.order_status[0] == '8'}">selected</c:if>>订单已评价</option>
									<option value = "9" <c:if test="${paraMap.order_status[0] == '9'}">selected</c:if>>订单已取消</option>
									<option value = "10" <c:if test="${paraMap.order_status[0] == '10'}">selected</c:if>>订单已付款</option>
								</select>
							</div>
							<button type="submit" class="btn btn-primary .badge" value="查询">查询</button>
						
						</form>
					</div>
				</div>
			</div>
		</header>

		<!-- 列表内容  -->
		<section class="scrollable wrapper">
			<section class="panel panel-default">
				<div class="table-responsive">
					<table class="table table-striped m-b-none">
						<thead>
							<tr>
								<th width="3%"></th>
								<th width="4%">序号</th>
								<th width="3%"><input type="checkbox" id="checkAll" /></th>
								<th width="10%">订单编号</th>
								<th width="9%">货主昵称</th>
								<th width="9%">车牌号</th>
								<th width="9%">车主姓名</th>
								<th width="10%">起始城市</th>
								<th width="10%">目的城市</th>
								<th width="9%">订单金额</th>
								<th width="9%">支付金额</td>
								<th width="10%">订单状态</th>
								<c:if test="${user_type_state == 3}"><th width="6%">支付状态</th></c:if>
							<!-- <th width="5%">确认到达</th> -->
								<th width="8%">操作</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach items="${pageList.getList()}" var="obj" varStatus="status">
								<tr height="25px">
									<td><a href="<%=basePath%>/OrderInfoAction/view?order_id=${obj.order_id}&is_same_city=${obj.is_same_city}">
									<i title="查看详情" class="fa fa-search-plus" ></i></a></td>
									<td>${(pageList.pageNumber - 1) * pageList.pageSize + status.index + 1}</td>
									<td><input type="checkbox" name="singleCheck" value="${obj.order_id}" exportType="${obj.is_export}" /></td>
									<td>${obj.order_code }</td>
									<td>${obj.nickname }</td>
									<td>${obj.car_number }</td>
									<td>${obj.driver_name }</td>
									<td>${obj.start_city }</td>
									<td>${obj.arrive_city }</td>
									<td>${obj.basic_amount }</td>
									<td>${obj.pay_driver_amount }</td>
									<td id="order_status_pay">
										<c:if test="${obj.order_status == 1}">订单已发布</c:if>
										<c:if test="${obj.order_status == 2}">订单已付款</c:if>
										<c:if test="${obj.order_status == 3}">已接单</c:if>
										<c:if test="${obj.order_status == 4}">取货中</c:if>
										<c:if test="${obj.order_status == 5}">送货中</c:if>
										<c:if test="${obj.order_status == 6}">货物已送达</c:if>
										<c:if test="${obj.order_status == 7}">已确认收货</c:if>
										<c:if test="${obj.order_status == 8}">订单已评价</c:if>
										<c:if test="${obj.order_status == 9}">订单已取消</c:if>
										<c:if test="${obj.order_status == 10}">订单已付款</c:if>
									</td>
						
									
								<c:if test="${user_type_state == 3}">
									<td>
									<!-- 物流公司后台支付运费和保险费 -->
					<%-- 				<c:if test="${obj.order_status == 1}">
											<button  type="button"  onclick="addPay('${obj.order_id}','${obj.order_status}','${obj.basic_amount }','${obj.user_id}')"   class="btn btn-primary .badge">
														待付款
											</button>
									</c:if>	
									<c:if test="${obj.order_status == 2}">
											<button  type="button"  onclick="addPay('${obj.order_id}','${obj.order_status}','${obj.insure_amount}','${obj.user_id}')"   class="btn btn-primary .badge">
														支付保险
											</button>
									</c:if>	
									 --%>
									<c:if test="${obj.order_status == 5}">
											<button  type="button"  onclick="addPay('${obj.order_id}','${obj.order_status}','${obj.basic_amount }','${obj.user_id}')"   class="btn btn-primary .badge">
														支付司机运费
											</button>
										
									</c:if>
									<c:if test="${obj.order_status == 6}">
											<button  type="button"  onclick="addPay('${obj.order_id}','${obj.order_status}','${obj.basic_amount }','${obj.user_id}')"   class="btn btn-primary .badge">
														支付司机运费
											</button>
									</c:if>
								</td>
								</c:if>
										
									
									<c:if test="${export_state == 1}">
									<td>
										<input type="checkbox" class="is_export_check"  ${obj.is_export == 1 ? 'checked' : ''} onchange="updateIsExport('${obj.order_id}');"/>
									</td>
									</c:if>
									<td><a target="_blank" style="text-decoration:underline;" href="<%=basePath%>/map/viewLine?order_id=${obj.order_id}&driver_id=${obj.driver_id }">查看轨迹</a></td>
								</tr>
							</c:forEach>
						</tbody>
						
						<!-- 底部的分页标签，注意要修改请求的路径和传递参数paraMap  -->
							<tfoot>
							<tr>
								<th colspan="10" class="row">
									<div class="datagrid-footer-left col-sm-3 text-center-xs m-l-n" style="visibility: visible;"></div>
									<div class="datagrid-footer-right col-sm-9 text-right text-center-xs" style="visibility: visible;">
										<page:page data="pageList" href="${contextPath}/OrderInfoAction?
										order_code=${paraMap.order_code[0]}&nickname=${paraMap.nickname[0]}&car_number=${paraMap.car_number[0]}&driver_name=${paraMap.driver_name[0]}
										&start_city=${paraMap.start_city[0]}&arrive_city=${paraMap.arrive_city[0]}&begin_date=${paraMap.begin_date[0]}&end_date=${paraMap.end_date[0]}&order_status=${paraMap.order_status[0]}" />
									</div>
								</th>
							</tr>
						</tfoot>
					</table>
				</div>
			</section>
		</section>
	</section>
		
<%-- 这是  运费 余额支付 和支付宝支付的弹出框
	<div class="container">
		<div class="modal fade" id="myModalPay" tabindex="-1" role="dialog"
			aria-labelledby="myModalLabel" aria-hidden="true">
			<div class="modal-dialog" style="width: 500px">
				<div class="modal-content">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal"
							aria-hidden="true">×</button>
						<h5 class="modal-title" id="myModalLabel">支付订单的运费</h5>
					</div> 
					<div class="modal-body">
						<section class="edit-map wrapper docs-pictures clearfix"
							id="edit_base">
							<div class="form-group m-b-xs">
								<label class="col-sm-4 control-label">订单运费：<span id="basic_order_amount"></span></label>
							</div>
						</section>
						<form action="" method="post">
							请选择支付方式：<br /> 
							
						<input type="radio" checked="checked" name="pd_FrpId" value="1" > 余额支付 &nbsp; &nbsp;<img src="<%=basePath%>/images/logo.png" align="middle" />
						<span style="color: orange"> 可用余额为：${balance }元</span>
						</input>
							<br /><br />
							 <input type="radio" name="pd_FrpId" value="3" /> 支付宝支付 <img src="<%=basePath%>/images/alipay.png" align="middle" />
						</form>
					</div>
					<div class="modal-footer">
						<button type="submit" id="btnSubmit"
							class="btn btn-primary pull-left" style="margin-left: 150px"
							onclick="addPayOrder();">确认支付</button>
						<button type="button" class="btn btn-primary pull-right"
							style="margin-right: 150px" data-dismiss="modal">取消</button>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="container">
		<div class="modal fade" id="myModalPayInsure" tabindex="-1" role="dialog"
			aria-labelledby="myModalLabel" aria-hidden="true">
			<div class="modal-dialog" style="width: 500px">
				<div class="modal-content">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal"
							aria-hidden="true">×</button>
						<h5 class="modal-title" id="myModalLabel">支付保险费</h5>
					</div> 
					<div class="modal-body">
						<section class="edit-map wrapper docs-pictures clearfix"
							id="edit_base">
							<div class="form-group m-b-xs">
								<label class="col-sm-4 control-label">保险费：<span id="basic_insure_amount"></span></label>
							</div>
						</section>
						<form action="" method="post">
							请选择支付方式：<br /> 
							 <input type="radio" name="alipay" value="3" /> 支付宝支付 <img src="<%=basePath%>/images/alipay.png" align="middle" />
						</form>
					</div>
					<div class="modal-footer">
						<button type="submit" id="btnSubmit"
							class="btn btn-primary pull-left" style="margin-left: 150px"
							onclick="addPayOrder();">确认支付</button>
						<button type="button" class="btn btn-primary pull-right"
							style="margin-right: 150px" data-dismiss="modal">取消</button>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	
	<div class="container">
		<div class="modal fade" id="myCode" tabindex="-1" role="dialog"
			aria-labelledby="myModalLabel" aria-hidden="true">
			<div class="modal-dialog" style="width: 500px">
				<div class="modal-content">
					<div class="modal-body">
					 	<div id="qr_code">
						
						</div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-primary pull-right"
							style="margin-right: 150px" data-dismiss="modal">取消</button>
					</div>
				</div>
			</div>
		</div>
	</div>
		
		 --%>
		
		
	<div class="container">
		<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
			<div class="modal-dialog" style="width:500px">
				<div class="modal-content">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
						<h4 class="modal-title" id="myModalLabel">请仔细填写支付给司机的运费</h4>
					</div>
					<div class="modal-body">
					  <section class="edit-map wrapper docs-pictures clearfix" id="edit_base">
							<div class="form-group m-b-xs">
								<label class="col-sm-4 control-label"><font class="red">* </font>支付司机运费：</label>
								<div class="col-sm-8">
									<input id="pay_driver_amount" placeholder="请谨慎输入运费" 
										maxLength="10" class="form-control" type="text" />
								</div>
							</div>
					   </section>
					</div>
					<div class="modal-footer">
						<button type="submit" id="btnSubmit" class="btn btn-primary pull-left" style="margin-left:150px" onclick="savePay();">确定</button>
		                <button type="button" class="btn btn-primary pull-right" style="margin-right:150px" data-dismiss="modal">取消</button>
		            </div>
				</div>
			</div>
		</div>
	</div>
	

</body>
<script type="text/javascript">
	var updateIsExport;

	$(function() {
	
		//全选/全不选
			$("#checkAll").click(function() {
			$('input[name="singleCheck"]').attr("checked", this.checked); 
			var allCheckBox = $("input[name='singleCheck']");
		    allCheckBox.click(function(){
		    	$("#checkAll").attr("checked", allCheckBox.length == $("input[name='singleCheck']:checked").length ? true : false);
		    });
		});
		
		
		
		updateIsExport = function(id){
			 $.ajax({
			    	type:"post",
			    	url:"<%=basePath%>/OrderInfoAction/updateIsExport/",
			    	data:"id="+id,
		 	     	error:function(){
		 	     		alert("系统异常！");
		 	     	},
		 	     	success:function(msg){
			 	       	if(msg=="200"){
			 	       		//alert("设置成功！");
			 	       		//$("#submitForm").submit(); //刷新列表
		 	       		}else{
				   			alert("系统异常！");
				   		}
		 	      	}
				});
		}

	});
	
	//删除
	function del(){
		var ids = [];
		var selectRow = $("input[name='singleCheck']:checked").each(function (){ //获取选中的行
			ids.push($(this).val());
	 	});
		if(selectRow.length < 1){
			alert("请选择要删除的记录！");
			return;
		}
		
		if(confirm("确定要删除选中记录吗？")){
	   	    $.ajax({
		    	type:"post",
		    	url:"<%=basePath%>/OrderInfoAction/delete/",
		    	data:"ids="+ids.join(","),
	 	     	error:function(){
					alert("删除失败！");
	 	     	},
	 	     	success:function(msg){
		 	       	if(msg=="200"){
		 	       		alert("删除成功！");
		 	       		$("#submitForm").submit(); //刷新列表
	 	       		}else{
			   			alert("删除失败！");
			   		}
	 	      	}
			});
		}
	}


	//导出
	function exportExcel(){
		var selectIds = "";
		var singleCheck =  $("input[name='singleCheck']:checked");
		var checkObj = singleCheck.each(function (i){
			if("${export_state}" != 1 || $(this).attr("exportType").indexOf("1") == -1 ){
				selectIds += $(this).val() + ",";	
			}
		});
		
		if(selectIds.length > 1){
			selectIds = selectIds.substring(0, selectIds.length -1);
		}
		if(singleCheck.length > 0 && selectIds == "" ){
			alert("请选择没有被标记的记录进行导出！");
		}else{
			
			window.location.href="<%=basePath%>/OrderInfoAction/exportExcel?ids="+selectIds+"&"+$("#submitForm").serialize(); 
 	<%-- 	window.location.href="<%=basePath%>/OrderInfoAction/exportExcel?ids="+selectIds+"&order_code=${paraMap.order_code[0]}&car_number=${paraMap.car_number[0]}&driver_name=${paraMap.driver_name[0]}&start_city=${paraMap.start_city[0]}&arrive_city=${paraMap.arrive_city[0]}&begin_date=${paraMap.begin_date[0]}&end_date=${paraMap.end_date[0]}&order_status=${paraMap.order_status[0]}";
 	 --%>
 	}
		
		
	}
</script>
</html>