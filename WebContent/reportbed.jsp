<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,java.text.*,javax.naming.*,javax.sql.*" %>
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

</style>
<script>

function PreCheck(a){
	 var limi = document.getElementsByName("limit")[0].value; 
	 
	 if(limi==null || limi==""){
		 limi="未限制!";
	 } else{
		 limi+="!";
	 }
	if (confirm("預定載入數量為:"+limi,"確定","取消")) {
		ActionDeterminator(a)
	} 

}

function ActionDeterminator(a) {
  if (a == 2) {
    document.getElementById('form1').action = 'excel.jsp';
  }
  if(a == 1) {
    document.getElementById('form1').action = 'reportbed.jsp';
  }
	document.getElementById('form1').submit();
}
</script>
</head>

<body>
<%
	if (session.getAttribute("mytype")==null){
		response.sendRedirect("index.html");
		return;
	}
String u=null;
if (((String)session.getAttribute("mytype")).equals("99")){
	u=request.getParameter("userid");
}else{
	u=(String)session.getAttribute("memberid");
}
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
    <td><input name="userid" type="text" maxlength="20" /></td>
    <td>&nbsp;</td>
  </tr>
<%
}
%>
  <tr>
    <td align="right"><label>狀態</label></td>
    <td><input name="status" type="text" maxlength="20" /></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td align="right"><label>載入數量</label></td>
    <td><input name="limit" type="text" maxlength="20" /></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td align="right"><label>Message ID</label></td>
    <td><input name="msgid" type="text" maxlength="40" /></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td align="right"><label>建立日期</label></td>
    <td>
		    <input type="text" id="dfrom" name="dfrom" size="10" readonly>
    <input type="button" value="..." id="BTN" name="BTN">
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
		    <input type="text" id="dto" name="dto" size="10" readonly>
    <input type="button" value="..." id="BTN1" name="BTN1">
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
    <td colspan="2" align="center"><input name="button1" type="button" value="送出" onclick="PreCheck(1);"/><input name="button2" type="button" value="Excel" onclick="PreCheck(2);"/><span>Excel將依據查詢條件進行轉出</span></td>
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
String rMsg="";
String m=request.getParameter("msgid");
String f=request.getParameter("dfrom");
String t=request.getParameter("dto");
String s=request.getParameter("status");
String l=request.getParameter("limit");
SimpleDateFormat fromUser = new SimpleDateFormat("yyyyMMddHHmmss");
SimpleDateFormat fromInput = new SimpleDateFormat("yyyy/MM/dd");
SimpleDateFormat myFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
if (u!=null||m!=null||f!=null||t!=null||s!=null){
	if ((f!=null&&t==null)||(t!=null&&f==null)){
		out.print("<font color='red'>日期必需輸入起及迄</font>");
		return;
	}
        if (f!=null&&t!=null)
	if ((!f.equals("")&&t.equals(""))||(!t.equals("")&&f.equals(""))){
		out.print("<font color='red'>日期必需輸入起及迄</font>");
		return;
	}
    if(s!=null && !s.equals("")){
    	 try {  
             Integer.parseInt(s);  
         } catch (NumberFormatException e) {  
        	 out.print("狀態代碼必須為數字");
             return ;  
         }  
    }
	if(l!=null && !l.equals("")){
		try {  
            Integer.parseInt(l);  
        } catch (NumberFormatException e) {  
       	 out.print("載入數量必須為數字");
            return ;  
        }  
    }
	String sql="select s.userid,i.msgid,seq,schedule,phoneno,msgbody,tries,status,donetime,m.createtime,orgcode from smppuser s, messages m, msgitem i where s.userid=m.userid and i.msgid=m.msgid ";
	String cc="";
	if (u!=null)
	if (!u.equals("")){
		cc+="and s.userid=?  ";
	}
	if (m!=null){
		if (!m.equals(""))
			cc+="and i.msgid=?  ";
	}
	if (s!=null){
		if (!s.equals(""))
			cc+="and i.status=?  ";
	}
	
	/*
	if (r!=null){
		cc+="and i.rid=?  ";
	}
	*/
	if (f!=null&&t!=null)
  if (!f.equals("")&&!t.equals("")){
		cc+="and m.createtime >=? and m.createtime<=? ";
		f=fromUser.format(fromInput.parse(f));
		t=fromUser.format(fromInput.parse(t));
		t=t.substring(0,8)+"235959";
		out.println(t);
	}
	
	PreparedStatement ps=null;
	ResultSet rs = null;
	Context ctx = new InitialContext();
	Context env=(Context)ctx.lookup("java:comp/env");
	DataSource ds =(DataSource)env.lookup("jdbc/SMPPDB");        
	Connection conn = ds.getConnection();
	//String [] statusmsg={"未發送","交換機已轉送","已送出","已到期","已刪除","無法送出","交換機已收到","未知","拒絕"};
	String [] statusmsg={"未發送","交換機已轉送","已送出","已到期","已刪除","無法送出","交換機已收到","未知","拒絕","已送出",
            "10","11","12","13","14","15","16","17","18","19",
			 "20","21","22","23","24","25","26","27","28","29",
			 "30","31","32","33","34","35","36","37","38","39",
			 "40","41","42","43","44","45","46","47","48","49",
			 "50","51","52","53","54","55","56","57","58","59",
			 "60","61","62","63","64","65","66","67","68","69",
			 "70","71","72","73","74","75","76","77","78","79",
			 "80","81","82","83","84","85","86","87","88","89",
			 "90","91","92","93","94","95","96","查詢中(97)","處理中(98)","排程中(99)"};
	try {
		
		cc+=" order by s.userid,createtime desc,i.msgid";
		
		if (l!=null){
			if (!l.equals(""))
				cc+=" limit ? ";
		}
		ps = conn.prepareStatement(sql+cc);
		int pcount=1;
//out.print(sql+cc+" order by s.userid,createtime desc,i.msgid");
		if (u!=null)
    if (!u.equals("")){
			ps.setString(pcount,u);
			pcount++;
		}
		if (m!=null)
    if (!m.equals("")){
			ps.setString(pcount,m);
			pcount++;
		}
		/*
		if (r!=null){
			ps.setString(pcount,r);
			pcount++;
		}
		*/
		if (f!=null&&t!=null)
    if (!f.equals("")&&!t.equals("")){
			ps.setString(pcount,f);
			pcount++;
			ps.setString(pcount,t);
			pcount++;
		}
		
	if (!s.equals("")){
			ps.setInt(pcount,Integer.parseInt(s));
			pcount++;
		}
	
	if (!l.equals("")){
			ps.setInt(pcount,Integer.parseInt(l));
			pcount++;
		}
		rs = ps.executeQuery();
%>
<table border="1" cellpadding="0" cellspacing="0" width="1383">
    <tr height="27">
      <td bgcolor="navy" width="331" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">Message ID</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="117" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">組織代碼</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="44" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">序號</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="155" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">訂單接收時間</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="155" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">預計發送日期</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="155" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">完成時間</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="111" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">手機號碼</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="60" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">狀態</font><u></u><u></u></span></p></td>
      <td bgcolor="navy" width="256" height="27"><p align="center"><span lang="EN-US" xml:lang="EN-US"><font color="white">訊息</font><u></u><u></u></span></p></td>
    </tr>
<%
		String rsMsgid="";
		int fcount=0;
		int scount=0;
		int tcount=0;
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
%>
    <tr height="27">
      <td nowrap="nowrap" width="331" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("msgid")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="117" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("orgcode")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="44" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("seq")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="155" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=myFormat.format(fromUser.parse(rs.getString("createtime")))%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="155" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("schedule")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="155" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=myFormat.format(fromUser.parse(rs.getString("donetime")))%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="111" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("phoneno")%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="60" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=statusmsg[rs.getInt("status")]%><u></u><u></u></span></p></td>
      <td nowrap="nowrap" width="256" height="27"><p><span lang="EN-US" xml:lang="EN-US"><%=rs.getString("msgbody")%><u></u><u></u></span></p></td>
    </tr>
<%
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
%>
  <tr>
		<td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="3">總計</td>
    <td><%=tcount%></td>
  </tr>
<%
	} catch (SQLException sqle) {
		rMsg="Query Exception:"+sqle.getMessage();
		out.println(rMsg);
	}finally{
		try{
			rs.close();
			ps.close();
			conn.close();
		}catch(Exception e){
		}
%>
</table>
<p>
  <%
	}
}//check if there submit something
%>
</p>
</body>
</html>
