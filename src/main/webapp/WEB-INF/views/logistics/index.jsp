<%@page import="com.nzonly.tb.entity.TaobaoTrade"%>
<%@page import="com.nzonly.tb.Constants"%>
<%@ page pageEncoding="UTF-8" %>
<%@ include file="../tag.jsp" %>
<html>
<head>
	<title>运单信息</title>
</head>
<body>

<div class="title">
	<p>订单信息</p>	
</div>

<div class="options">
	选择日期: &nbsp; 开始 <input type="text" name="start" id="start" readonly="readonly" /> &nbsp;&nbsp; 结束 <input type="text" name="end" id="end"  readonly="readonly" />
	<button id="sync">同步</button>
</div>


<c:if test="${!empty list.content}">
<div class="table-result-wrap">
	
	<table class="result">
		<thead>
			<tr>
				<th>淘宝交易号</th>
				<th>运单号</th>
				<th>买家昵称</th>
				<th>物流公司名称</th>
				<th>货物名称</th>
				<th>运单号</th>
				<th>运单创建时间</th>
				<th>收件人姓名</th>
				<th>收件人电话</th>
				<th>收件人手机号码</th>
				<th>本地最后处理时间</th>
				<th>本地备注</th>
			</tr>
		</thead>
		<tbody>
			<c:forEach var="item" items="${list.content}">
			<tr>
				<td>
					<a href="http://trade.taobao.com/trade/detail/trade_item_detail.htm?bizOrderId=${item.tid}" target="_blank">${item.tid}</a>
				</td>
				<td>
					${item.outSid}
				</td>
				<td>
					${item.buyerNick}
					
					<a target="_blank"	href="http://www.taobao.com/webww/ww.php?ver=3&touid=${item.buyerNick}&siteid=cntaobao&status=2&charset=utf-8"><img src="http://amos.alicdn.com/realonline.aw?v=2&uid=${item.buyerNick}i&site=cntaobao&s=2&charset=utf-8" alt="发消息" /></a>
				</td>
				<td>
					${item.companyName}
				</td>
				<td>
					${item.itemTitle}
				</td>
				<td>
					${item.outSid}
				</td>
				<td>
					<fmt:formatDate value="${item.created}" pattern="yyyy-MM-dd HH:mm:ss" />
				</td>
				<td>
					${item.receiverName}
				</td>
				<td>
					${item.receiverMobile}
				</td>
				<td>
					${item.receiverPhone}
				</td>
				<td>
					<fmt:formatDate value="${item.lastUpdateTime}" pattern="yyyy-MM-dd HH:mm:ss" />
				</td>
				<td>
					${item.note}
				</td>
			</tr>
			</c:forEach>
		</tbody>
	</table>
	<!-- pagebar start -->
	<pagebar:pagebar total="${list.totalPages}" current="${list.number + 1}" />
	<!-- #pagebar end -->
	
</div>
</c:if>
<c:if test="${empty list.content}">
	<p class="empty">No data</p>
</c:if>
<content tag="javascript">
<%@ include file="../jqueryui.jsp" %>
<script type="text/javascript">
// DOM Ready
$(function() {
	$("#start").datepicker({
		dateFormat: "yy-mm-dd",
		onSelect: function( selectedDate ) {
			var d = new Date(selectedDate);
			d.setDate(d.getDate() + 90);
			$("#end").datepicker("option", "minDate", selectedDate);
			$("#end").datepicker("option", "maxDate", d);
		}
	});	
	
	$("#end").datepicker({
		dateFormat: "yy-mm-dd",
		onSelect: function( selectedDate ) {
			var d = new Date(selectedDate);
			d.setDate(d.getDate() - 90);
			$("#start").datepicker("option", "maxDate", selectedDate);
			$("#start").datepicker("option", "minDate", d);
		}
	});
	
	var processDialog = {
		show: function() {
			$("#dialog:ui-dialog").dialog( "destroy" );
			$("#dialog-modal").dialog({
				draggable: false,
				resizable: false,
				height: 90,
				modal: true,
				close: function() {
					alert("注意: 您的任务已在后台运行~ 无法取消");
				}
			});
		},
		close: function() {
			$("#dialog:ui-dialog").dialog( "destroy" );
			$('.ui-dialog-titlebar-close').trigger('click');
		},
		process: function(i) {
			$("#progressbar").progressbar({
				value: i
			});
		}		
	};
	
	$("#sync").click(function() {
		processDialog.show();
		processDialog.process(0);
		
		var checker = null;
		
		if ($("#start").val() == '' || $("#end").val() == '') {
			alert('请填写起始和结束时间');
		}
		
		$.ajax({
			url: "${ctx}/ajax/logistics/sync",
			type: "POST",
			data: {start: $("#start").val(), end:$("#end").val()},
			success: function() {
				checker = setInterval(function() {
					$.ajax({
						cache: false,
						url: "${ctx}/ajax/logistics/process",
						success: function(r) {
							var i = parseInt(r);
							if (i >= 100) {
								processDialog.process(100);
								if (checker) {
				 					clearInterval(checker);
				 				}
								alert("任务执行完毕!");
								location.reload();
							}
							processDialog.process(i);
						},
						error: function() {
							location.reload();
						}
					});
				}, 600);
			},
			error: function() {
 				alert("Error!");
				processDialog.close();
				location.reload();
			}
		});
	});
});
</script>

<div id="dialog-modal" title="正在同步">
	<style>.ui-progressbar .ui-progressbar-value { background-image: url(${ctx}/static/jquery-ui/css/ui-lightness/images/pbar-ani.gif); }</style>
	<div id="progressbar" style="margin-top: 10px;"></div>
</div>

</content>
</body>
</html>