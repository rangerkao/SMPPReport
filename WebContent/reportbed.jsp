<%@page import="javax.swing.text.Document"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,java.text.*,javax.naming.*,javax.sql.*,java.io.*" %>
<%@ page  import="org.apache.poi.hssf.usermodel.*,org.apache.poi.hssf.util.*,org.apache.xmlbeans.XmlObject,org.apache.poi.ss.usermodel.*" %>
<%@ page import="java.text.SimpleDateFormat"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>管理</title>
    <script type="text/javascript" src="JSCal2-1.7/src/js/jscal2.js"></script>
    <script type="text/javascript" src="JSCal2-1.7/src/js/lang/b5.js"></script>
    <link type="text/css" rel="stylesheet" href="JSCal2-1.7/src/css/jscal2.css" />
<style type="text/css">

.basictab{
padding: 3px 0;
margin-left: 0;
font: bold 12px Verdana;
border-bottom: 1px solid gray;
list-style-type: none;
text-align: left; /*set to left, center, or right to align the menu as desired*/
}

.basictab li{
display: inline;
margin: 0;
}

.basictab li a{
text-decoration: none;
padding: 3px 7px;
margin-right: 3px;
border: 1px solid gray;
border-bottom: none;
background-color: #f6ffd5;
color: #2d2b2b;
}

.basictab li a:visited{
color: #2d2b2b;
}

.basictab li a:hover{
background-color: #DBFF6C;
color: black;
}

.basictab li a:active{
color: black;
}

.basictab li.selected a{ /*selected tab effect*/
position: relative;
top: 1px;
padding-top: 4px;
background-color: #DBFF6C;
color: black;
}
 .button{
                background-color:#1C2045;
                color:#E7C254;
                padding:5px 20px;
                max-width: 300px;
                line-height:1.5em;
                text-align:center;
                margin:5px auto;
            }
            .button a{ color:#E7C254;}
            .refs{ display:block; margin:auto; text-align:left; max-width:500px; }
            .refs .label{  font-size:1.4em;}
            .refs > ul{ margin-top:10px; line-height:1.5em;}

</style>
<script type='text/javascript' src='https://code.jquery.com/jquery-1.11.0.min.js'></script>
<script>

function PreCheck(a){
	 var limi = document.getElementsByName("limit")[0].value; 
	 
	 if(limi==null || limi==""){
		 limi="未限制!";
	 } else{
		 limi+="!";
	 }
	if (confirm("預定載入數量為:"+limi,"確定","取消")) {
		ActionDeterminator(a);
	} 

}

function ActionDeterminator(a) {
  if (a == 2) {
    //document.getElementById('form1').action = 'excel.jsp';
	  document.getElementById('form1').action = 'reportbed.jsp?exportToExcel=YES';
  }
  if(a == 1) {
    document.getElementById('form1').action = 'reportbed.jsp';
  }
	document.getElementById('form1').submit();
}

function inputClear(){
	var tag =document.getElementsByTagName('input');
	for(var i=0;i<tag.length;i++){
		if(tag[i].type=='text')
			tag[i].value="";
	};
	document.getElementsByTagName('select')[0].value="";
}
</script>
</head>


<body>
<%
	//auther check
	if (session.getAttribute("mytype")==null){
		response.sendRedirect("index.html");
		return;
	}
	
	//user check
	String u=null;
	if (((String)session.getAttribute("mytype")).equals("99")){
		u=request.getParameter("userid")!=null?request.getParameter("userid"):"";
	}else{
		u=(String)session.getAttribute("memberid")!=null?(String)session.getAttribute("memberid"):"";
	}
	
	//map setting
	Map <Integer,String>map = new HashMap<Integer,String>();
	/* map.put(0,"未發送");
	map.put(1,"交換機已轉送");
	map.put(2,"已送出");
	map.put(3,"已到期");
	map.put(4,"已刪除");
	map.put(5,"無法送出");
	map.put(6,"交換機已收到");
	map.put(7,"未知");
	map.put(8,"拒絕");
	map.put(9,"已送出");
	map.put(95,"傳送失敗");
	map.put(96,"逾期");
	map.put(97,"查詢中");
	map.put(98,"處理中");
	map.put(99,"排程中"); */
	
	//20150324 change
	//20150715 add status 94 fail by got negetiveresponse
	map.put(0,"傳送中");
	map.put(1,"傳送中");
	map.put(2,"成功");
	map.put(3,"失敗");
	map.put(4,"失敗");
	map.put(5,"失敗");
	map.put(6,"傳送中");
	map.put(7,"失敗");
	map.put(8,"失敗");
	map.put(9,"成功");
	map.put(94,"亞太用戶");
	map.put(95,"傳送中");
	map.put(96,"失敗");
	map.put(97,"傳送中");
	map.put(98,"傳送中");
	map.put(99,"傳送中");
	
	String rMsg="";
	String pLog=(request.getParameter("pLog")!=null?request.getParameter("pLog"):"");
	String m=request.getParameter("msgid")!=null?request.getParameter("msgid"):"";
	String f=request.getParameter("dfrom")!=null?request.getParameter("dfrom"):"";
	String t=request.getParameter("dto")!=null?request.getParameter("dto"):"";
	String s=request.getParameter("status")!=null?request.getParameter("status"):"";
	String l=request.getParameter("limit")!=null?request.getParameter("limit"):"";
	SimpleDateFormat fromUser = new SimpleDateFormat("yyyyMMddHHmmss");
	SimpleDateFormat fromInput = new SimpleDateFormat("yyyy/MM/dd");
	SimpleDateFormat myFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
	
	
	String exportToExcel = request.getParameter("exportToExcel");
	boolean excelMode= false;
	if(exportToExcel != null && exportToExcel.toString().equalsIgnoreCase("YES"))
		{excelMode=true;}
	
	String WebDirPath = request.getRealPath("/");
	HSSFWorkbook  	wb  	= new HSSFWorkbook();
	HSSFSheet		sheet	= wb.createSheet();
  	HSSFRow 		row		= null;                 
  	HSSFCell 		cell	= null;      
  	
  	int rowCount=0;
  	int cellCount=0;
	
	if(excelMode){
		//XXX
	}else{

%>

		<ul class="basictab">
		<li><a href="adminbed.jsp">客戶管理</a></li>
		<li class="selected"><a href="reportbed.jsp">報表查詢</a></li>
		</ul>
		<table width="100%" border="0" align="center">
		  <tr>
		    <td width="10%">&nbsp;</td>
		    <td width="80%" align="center">報表</td>
		    <td width="10%">&nbsp;</td>
		  </tr>
		  <tr>
		    <td width="10%">&nbsp;</td>
		    <td width="80%">
		<form id="form1" name="form1" method="post" action="">
		    <table width="100%" border="0">
		  <tr>
		    <td width="30%">&nbsp;</td>
		    <td width="40%">&nbsp;</td>
		    <td width="30%">&nbsp;</td>
		  </tr>
<%
		if (((String)session.getAttribute("mytype")).equals("99")){
%>
			  <tr>
			    <td align="right"><label>客戶代碼</label></td>
			    <td><input name="userid" type="text" maxlength="20" value="<%=u%>" /></td>
			    <td></td>
			  </tr>
<%
		}
%>
		  <tr style="display: none;">
		  	<td><input type="text" value="yes" name="pLog"/></td>
		  </tr>
		  <tr>
		    <td align="right"><label>狀態</label></td>
		    <td><!-- <input name="status" type="text" maxlength="20" /> -->
		   		<select name="status">
		   		<option value="">全部</option>
		   		<%--20150713 add --%>
		   		<option value="(0,1,6,95,97,98,99)" <%out.print("(0,1,6,95,97,98,99)".equalsIgnoreCase(s)?"selected":""); %>>轉送中</option>
		   		<option value="(2)" <%out.print("(2)".equalsIgnoreCase(s)?"selected":""); %>>成功</option>
		   		<option value="(3,4,5,7,8,96)" <%out.print("(3,4,5,7,8,96)".equalsIgnoreCase(s)?"selected":""); %>>失敗</option>
		   		<option value="(94)" <%out.print("(94)".equalsIgnoreCase(s)?"selected":""); %>>亞太用戶</option>
		   		<%-- <%
				
		   		for(Integer item : map.keySet()){
		   			out.print("<option value="+item+">"+map.get(item)+"</option>");
		   		}
		   		%> --%>
				    <%-- <option value="1">1</option>--%>
				</select>
		    </td>
		    <td>&nbsp;</td>
		  </tr>
		  <tr>
		    <td align="right"><label>載入數量</label></td>
		    <td><input name="limit" type="text" maxlength="20" value="<%=l%>"/></td>
		    <td>&nbsp;</td>
		  </tr>
		  <tr>
		    <td align="right"><label>Message ID</label></td>
		    <td><input name="msgid" type="text" maxlength="40" value="<%=m%>"/></td>
		    <td>&nbsp;</td>
		  </tr>
		  <tr>
		    <td align="right"><label>建立日期</label></td>
		    <td>
				    <input type="text" id="dfrom" name="dfrom" size="10" value="<%=f%>" readonly />
		    <input type="button" value="..." id="BTN" name="BTN" />
		    <script type="text/javascript">
		        new Calendar({
		            inputField: "dfrom",
		            dateFormat: "%Y/%m/%d",
		            trigger: "BTN",
		            bottomBar: true,
		            weekNumbers: true,
		            showTime: 24,
		            onSelect: function() {this.hide();}
		        });
		    </script>
		    
				    <input type="text" id="dto" name="dto" size="10" value="<%=t%>"readonly/>
		    <input type="button" value="..." id="BTN1" name="BTN1"/>
		    <script type="text/javascript">
		        new Calendar({
		            inputField: "dto",
		            dateFormat: "%Y/%m/%d",
		            trigger: "BTN1",
		            bottomBar: true,
		            weekNumbers: true,
		            showTime: 24,
		            onSelect: function() {this.hide();}
		        });
		    </script>
				</td>
		    <td>&nbsp;</td>
		  </tr>
		  <tr align="center">
		  	<td>&nbsp;</td>
		    <td colspan="2" align="center">
		    	<input name="button0" type="button" value="清除" onclick="inputClear();"/>
		    	<input name="button1" type="button" value="送出" onclick="PreCheck(1);"/>
	    		<input name="button2" type="button" value="Excel(Excel將依據查詢條件進行轉出)" onclick="PreCheck(2);"/>
	    		<!-- <input type="button" onclick="tableToExcel('result', 'W3C Example Table')" value="Export to Excel"/>
	    		<div class='button'>
                <a href="#" id ="export" role='button'>Click On This Here Link To Export The Table Data into a CSV File
                </a> 
            	</div>-->
    		</td>
		    <td>&nbsp;</td>
		  </tr>
		</table>    
		    </form></td>
		    <td width="10%">&nbsp;</td>
		  </tr>
		  <tr >
		    <td width="10%">&nbsp;</td>
		    <td width="80%">&nbsp;</td>
		    <td width="10%">&nbsp;</td>
		  </tr>
		</table>
<%
	}
//有參數輸入才顯示表格
if (u!=null||m!=null||f!=null||t!=null||s!=null){
	//error check
	if ((f!=null&&t==null)||(t!=null&&f==null)){
		out.print("<font color='red'>日期必需輸入起及迄</font>");
		wb.close();
		return;
	}
        if (f!=null&&t!=null)
	if ((!f.equals("")&&t.equals(""))||(!t.equals("")&&f.equals(""))){
		out.print("<font color='red'>日期必需輸入起及迄</font>");
		wb.close();
		return;
	}
	if(l!=null && !"".equals(l)){
		try {  
            Integer.parseInt(l);  
        } catch (NumberFormatException e) {  
       	 out.print("載入數量必須為數字");
       	wb.close();
            return ;  
        }  
    }
	
	String sql="select s.userid,i.msgid,i.seq,schedule,phoneno,msgbody,tries,status,donetime,m.createtime,orgcode, case when i.status=2 then coalesce(l.sum,1) else 0 end sum "
			+ "from smppuser s, messages m, msgitem i left outer join (select msgid,seq,count(1) sum from longmsgitem group by msgid,seq) l on i.msgid=l.msgid and i.seq=l.seq "
			+ "where s.userid=m.userid and i.msgid=m.msgid ";
	String sql2="select count(*) c from smppuser s, messages m, msgitem i where s.userid=m.userid and i.msgid=m.msgid ";
	
	String cc="";
	if (u!=null && !"".equals(u)){
		cc+="and s.userid=?  ";
	}
	if (m!=null && !"".equals(m)){
		cc+="and i.msgid=?  ";
	}
  	if (f!=null && !"".equals(f)&&t!=null && !"".equals(t)){
		cc+="and m.createtime >=? and m.createtime<=? ";
		f=fromUser.format(fromInput.parse(f));
		t=fromUser.format(fromInput.parse(t));
		t=t.substring(0,8)+"235959";
	}
	if (s!=null && !"".equals(s)){
			cc+="and i.status in "+s+" ";
	}
	
	PreparedStatement ps=null,ps2=null;
	ResultSet rs = null;
	Context ctx = new InitialContext();
	Context env=(Context)ctx.lookup("java:comp/env");
	DataSource ds =(DataSource)env.lookup("jdbc/SMPPDB");        
	Connection conn = ds.getConnection();
	try {
		ps2 = conn.prepareStatement(sql2+cc);
		cc+=" order by s.userid,createtime desc,i.msgid";
		
		if (l!=null && !"".equals(l)){
			if (!l.equals(""))
				cc+=" limit ? ";
		}
		
		ps = conn.prepareStatement(sql+cc);
		//parameter setting
		int pcount=1;

	    if (u!=null && !"".equals(u)){
				ps.setString(pcount,u);
				ps2.setString(pcount,u);
				pcount++;
		}

    	if (m!=null && !"".equals(m)){
			ps.setString(pcount,m);
			ps2.setString(pcount,m);
			pcount++;
		}
    	if (f!=null && !"".equals(f) && t!=null && !"".equals(t)){
			ps.setString(pcount,f);
			ps2.setString(pcount,f);
			pcount++;
			ps.setString(pcount,t);
			ps2.setString(pcount,t);
			pcount++;
		}
		if (l!=null && !"".equals(l)){
			ps.setInt(pcount,Integer.parseInt(l));
			pcount++;
		}

		ps2.executeQuery();
		int total=0;
		
		ResultSet rs2=ps2.executeQuery();
		
		if(rs2.next())
			total=rs2.getInt("c");
		//int total=ps2.executeQuery().getInt(0);
		
		//以pLog為記錄是否為首次登入網頁，20141125 add 首次進入時不預載資料
		if(pLog!=null && pLog!="")
			rs = ps.executeQuery();
		
		
		if(excelMode){
			row = sheet.createRow(rowCount++);
			
			HSSFCellStyle style1 = wb.createCellStyle();
			style1.setFillForegroundColor(HSSFColor.BLUE.index);
			style1.setFillPattern((short)1);

			Font font = wb.createFont();
	        font.setColor(HSSFColor.WHITE.index);
			style1.setFont(font); 
			
			//style1.setFillBackgroundColor(bg)
			row = sheet.createRow(rowCount++);
			cellCount = 0;
			cell = row.createCell(cellCount++);
			cell.setCellValue("Totla:");
			cell.setCellStyle(style1);
			
			cell = row.createCell(cellCount++);
			cell.setCellValue(total);
			cell.setCellStyle(style1);
			
			sheet.addMergedRegion(new CellRangeAddress(rowCount-1,rowCount-1,cellCount,cellCount+7));
			cell = row.createCell(cellCount++);
			cell.setCellValue(" ");
			cell.setCellStyle(style1);
			
			//****************
			row = sheet.createRow(rowCount++);
			cellCount = 0;
			cell = row.createCell(cellCount++);
			cell.setCellValue("Message ID");
			cell.setCellStyle(style1);
			
			cell = row.createCell(cellCount++);
			cell.setCellValue("組織代碼");
			cell.setCellStyle(style1);
			
			cell = row.createCell(cellCount++);
			cell.setCellValue("序號");
			cell.setCellStyle(style1);
			
			cell = row.createCell(cellCount++);
			cell.setCellValue("則數");
			cell.setCellStyle(style1);
			
			cell = row.createCell(cellCount++);
			cell.setCellValue("訂單接收時間");
			cell.setCellStyle(style1);
			
			cell = row.createCell(cellCount++);
			cell.setCellValue("預計發送日期");
			cell.setCellStyle(style1);
			
			cell = row.createCell(cellCount++);
			cell.setCellValue("完成時間");
			cell.setCellStyle(style1);
			
			cell = row.createCell(cellCount++);
			cell.setCellValue("手機號碼");
			cell.setCellStyle(style1);
			
			cell = row.createCell(cellCount++);
			cell.setCellValue("狀態");
			cell.setCellStyle(style1);
			
			cell = row.createCell(cellCount++);
			cell.setCellValue("訊息");
			cell.setCellStyle(style1);
			
		}else{
%>
	<table border="1" cellpadding="0" cellspacing="0" width="1383" id="result">
		<tr>
	      <td bgcolor="navy" width="331" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">Totla:</font><u></u><u></u></span></p></td>
	      <td bgcolor="navy" width="331" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white"><%= total %></font><u></u><u></u></span></p></td>
		  <td colspan="8"    bgcolor="navy" width="331" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">&nbsp;</font><u></u><u></u></span></p></td>
		</tr>
	    <tr height="27">
	      <td bgcolor="navy" width="331" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">Message ID</font><u></u><u></u></span></p></td>
	      <td bgcolor="navy" width="117" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">組織代碼</font><u></u><u></u></span></p></td>
	      <td bgcolor="navy" width="44" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">序號</font><u></u><u></u></span></p></td>
	      <td bgcolor="navy" width="44" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">則數</font><u></u><u></u></span></p></td>
	      <td bgcolor="navy" width="155" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">訂單接收時間</font><u></u><u></u></span></p></td>
	      <td bgcolor="navy" width="155" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">預計發送日期</font><u></u><u></u></span></p></td>
	      <td bgcolor="navy" width="155" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">完成時間</font><u></u><u></u></span></p></td>
	      <td bgcolor="navy" width="111" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">手機號碼</font><u></u><u></u></span></p></td>
	      <td bgcolor="navy" width="60" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">狀態</font><u></u><u></u></span></p></td>
	      <td bgcolor="navy" width="256" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">訊息</font><u></u><u></u></span></p></td>
	    </tr>
<%
		}
		String rsMsgid="";
		int fcount=0;
		int scount=0;
		int tcount=0;
		if(rs!=null){
			while (rs.next()){
				if (rs.getString("msgid").equals(rsMsgid)){
					if (!rsMsgid.equals("")){
%>
						  <tr>
								<td>&nbsp;</td>
						    <td>&nbsp;</td>
						    <td>&nbsp;</td>
						    <td>&nbsp;</td>
						    <td>&nbsp;</td>
						    <td align="right">發送失敗</td>
						    <td><%=fcount%></td>
						    <td>發送成功</td>
						    <td><%=scount%></td>
						  </tr>
<%
					}
					rsMsgid=rs.getString("msgid");
					fcount=0;
					scount=0;
				}
				fcount++;
				scount++;
				tcount++;
	
				String donetime="";
				 if(rs.getString("donetime")!=null&&!"".equals(rs.getString("donetime"))){
					donetime=myFormat.format(fromUser.parse(rs.getString("donetime")));
				} 
				String createtime="";
				if(rs.getString("createtime")!=null&&!"".equals(rs.getString("createtime"))){
					createtime=myFormat.format(fromUser.parse(rs.getString("createtime")));
				}
			
				
				if(excelMode){
					row = sheet.createRow(rowCount++);
					cellCount = 0;
					
					cell = row.createCell(cellCount++);
					cell.setCellValue(rs.getString("msgid"));
					
					cell = row.createCell(cellCount++);
					cell.setCellValue(rs.getString("orgcode"));
					
					cell = row.createCell(cellCount++);
					cell.setCellValue(rs.getString("seq"));
					
					cell = row.createCell(cellCount++);
					cell.setCellValue(rs.getString("sum"));
					
					cell = row.createCell(cellCount++);
					cell.setCellValue(createtime);
					
					cell = row.createCell(cellCount++);
					cell.setCellValue(rs.getString("schedule"));
					
					cell = row.createCell(cellCount++);
					cell.setCellValue(donetime);
					
					cell = row.createCell(cellCount++);
					cell.setCellValue(rs.getString("phoneno"));
					
					cell = row.createCell(cellCount++);
					cell.setCellValue(rs.getString("status"));
					
					cell = row.createCell(cellCount++);
					cell.setCellValue(rs.getString("msgbody"));
				
					
				}else{
%>
			    <tr  height="27">
			      <td nowrap="nowrap" width="331" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("msgid")%><u></u><u></u></span></p></td>
			      <td nowrap="nowrap" width="117" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("orgcode")%><u></u><u></u></span></p></td>
			      <td nowrap="nowrap" width="44" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("seq")%><u></u><u></u></span></p></td>
			      <td nowrap="nowrap" width="44" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("sum")%><u></u><u></u></span></p></td>
			      <td nowrap="nowrap" width="155" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=createtime%><u></u><u></u></span></p></td>
			      <td nowrap="nowrap" width="155" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("schedule")%><u></u><u></u></span></p></td>
			      <td nowrap="nowrap" width="155" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=donetime%><u></u><u></u></span></p></td>
			      <td nowrap="nowrap" width="111" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("phoneno")%><u></u><u></u></span></p></td>
			      <td nowrap="nowrap" width="60" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=map.get(rs.getInt("status"))%><u></u><u></u></span></p></td>
			      <td nowrap="nowrap" width="256" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("msgbody")%><u></u><u></u></span></p></td>
			    </tr>
<%
				}
			}
		}
		if (!rsMsgid.equals("")){
%>
			  <tr>
					<td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td>&nbsp;</td>
			    <td align="right">發送失敗</td>
			    <td><%=fcount%></td>
			    <td>發送成功</td>
			    <td><%=scount%></td>
			  </tr>
<%
		}
		if(excelMode){
			
			HSSFCellStyle style1 = wb.createCellStyle();
			style1.setFillForegroundColor(HSSFColor.BLUE.index);
			style1.setFillPattern((short)1);
			
			row = sheet.createRow(rowCount++);
			cellCount = 6;

			cell = row.createCell(cellCount++);
			cell.setCellValue("總計");
			
			cell = row.createCell(cellCount++);
			cell.setCellValue(tcount);
		}else{
%>
	<tr>
		<td>&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="3">總計</td>
	    <td><%=tcount%></td>
	</tr>
<%
		}
	} catch (SQLException sqle) {
		rMsg="Query Exception:"+sqle.getMessage();
		out.println(rMsg);
	}finally{
		try{
			rs.close();
			ps.close();
			ps2.close();
			conn.close();
		}catch(Exception e){
		}
%>
</table>
<p>
  <%
	}
}//check if there submit something

	if(excelMode){
		SimpleDateFormat SDF = new SimpleDateFormat("yyyyMMdd_HHmmss"); //日期格式
		  String fileNameDate = SDF.format(new java.util.Date());//把今天的日期格式化字串
		  
		   //儲存 excel 暫存檔
		  	String ExcelTempFilePath =fileNameDate+"_excelTemp.xls";
		   FileOutputStream fos =new FileOutputStream(WebDirPath + ExcelTempFilePath);
		   wb.write(fos);
		   fos.close();
		   wb.close();
		    
		   //=============取得TEMP檔案========================================================//
			File file = new File(WebDirPath + ExcelTempFilePath);
		   FileInputStream fis = new FileInputStream(file);
		 file.delete();
		  String filename = fileNameDate + "_sfle060.xls";
		 
		   //準備讓使用者下載檔案
		   out.clear();
		   //一定要加charset=iso-8859-1，否則文件內容會亂碼
		   //參考：http://www.west263.com/info/html/chengxusheji/Javajishu/20080225/33537.html
		   response.setContentType("application/octet-stream; charset=iso-8859-1;");
		   response.setHeader("content-disposition","attachment; filename="+filename);
		 
		   int byteRead;//設定int，等一下要讀檔用的
		 
		    //fis.read()會開始一個byte一個byte讀檔，讀到的byte傳給byteRead    
		    //若fis.read()傳回-1，表示讀完了
		 
		    while(-1 != (byteRead = fis.read()))
		      {
		        out.write(byteRead);
		      }
		    fis.close(); 
	}


%>
</p>
</body>
</html>
