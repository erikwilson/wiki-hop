<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.WikiHop.server.SearchPathRequest" %>
<%@ page import="java.net.URLDecoder" %>
<%
	String pageA = "", pageB = "", metaUrl = "", description = "";
	String title = "Wiki-Hop People Search";
	String result = "<div id='welcome'>"
			+ "<table style='width: 100%'><tbody><tr><td>"
			+ "<a href='http://www.wiki-hop.org/?/Paul_Erd%C5%91s//Kevin_Bacon'><img src='/sample.png' /></a>"
			+ "</td><td style='font-size:1.618em;'>"
			+ "<h2>Welcome to Wiki-Hop!</h2>"
			+ "<p>Begin by searching for names of people in Wikipedia... </p>"
			+ "<p><b><i>Example Search:</i></b> <a href='http://www.wiki-hop.org/?/Paul_Erd%C5%91s//Kevin_Bacon'>Paul Erdős to Kevin Bacon</a></p>"
			+ "<p><span id='readmore'>(<a href='http://blog.wiki-hop.org/2010/12/six-degrees.html' target='_blank'>more about wiki-hop</a>)</span></p>"
			+ "</td></tr></tbody></table>" + "</div>";
	String query = request.getQueryString();
	String oquery = query;
	if (query != null && !query.isEmpty()) {
		query = "?" + URLDecoder.decode(query, "UTF-8");

		if (query.matches("^\\?!?/.*")) {
			query = query
					.replaceFirst("^\\?!?", "?_escaped_fragment_=");
		}

		if (query.matches("^\\?a=.*&b=.*")) {
			query = query.replace("?a=", "?_escaped_fragment_=");
			query = query.replace("&b=", "//");
			query = query.replace("+", "_");
		}

		if (query.indexOf("?_escaped_fragment_=") == 0) {
			String anchor = query.substring(20);

			if (anchor.matches("^.*//.*")) {
				String[] p = anchor.split("//", -1);
				if (p.length == 2) {
					if (p[0].matches("^!.*")) p[0] = p[0].substring(1, p[0].length());
					if (p[0].matches("^/.*")) p[0] = p[0].substring(1, p[0].length());
					pageA = p[0].replace("\\/\\/\\", "//").replace("_"," ").trim();
					pageB = p[1].replace("\\/\\/\\", "//").replace("_"," ").trim();
					SearchPathRequest search = new SearchPathRequest();
					try {
						title = ("Wiki-Hop: "+pageA+" // "+pageB).replace("<", "&#60;").replace(">","&#62;");
						metaUrl = ("?/"+p[0]+"//"+p[1]).replace("\"", "%22");
						description = (", from " + pageA + " to " + pageB).replace("\"", "&#34;");
						result = search.find(pageA, pageB);
					} catch (Exception e) {
						result = "<span class='serverResponseLabelError'>"+e.getMessage()+"</span>";
					}
				}
			}
		}
	}
%>

<!doctype html>
<html>
	<head>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8">
		<link rel="icon" type="image/png" href="/favicon.ico"> 
		<title><%=title%></title>
		<script type="text/javascript" language="javascript" src="WikiHopPath/WikiHopPath.nocache.js"></script>	
		<link type="text/css" rel="stylesheet" href="WikiHop.css">

		<meta property="og:title" content="<%=title.replace("\"", "&#34;")%>"/>
		<meta property="og:type" content="website"/>
		<meta property="og:url" content="http://www.wiki-hop.org/<%=metaUrl%>"/>
		<meta property="og:image" content="http://www.wiki-hop.org/wiki-hop.png"/>
		<meta property="og:site_name" content="Wiki-Hop"/>
		<meta property="fb:admins" content="100001097488210"/>
		<meta property="og:description" content="Six degrees of separation in Wikipedia<%=description%>."/>		
	</head>
	<body>
	
		<div id='summary'>
			Wiki-Hop is a search engine for finding connections between people on Wikipedia.org.
			Search results provide a six degrees of separation style chain of Wikipedia links for users to explore new pages, such as artists, politicians, and important historical figures.		
		</div>
	
		<iframe src="javascript:''" id="__gwt_historyFrame" tabIndex='-1' style="position:absolute;width:0;height:0;border:0"></iframe>
	
		<script type="text/javascript">
			document.write("<style type='text/css'>.noscript { display: none; } .showscript { display: inline; }</style>");
		</script>
		
		<div id='center'>
		    <a href='/#'><div id="logo"></div></a>
		    <div id="wikiHopPath">
				<span class='noscript'>    
			      	<form action="/" method="get"><fieldset style="width: 35em; position: absolute; left: 0px; top: 0px;">
					<legend>Search for People in Wikipedia.org</legend>
					<table style="width: 100%;"><tbody>
					<tr>
					<td><div style="text-align: right; white-space: nowrap;" class="gwt-Label">From Page</div></td>
					<td><input style="width: 100%;" class="nojs-SuggestBox" type="text" name="a" value="<%=pageA.replace("\"", "&#34;")%>"></td>
					</tr><tr>
					<td><div style="text-align: right; white-space: nowrap;" class="gwt-Label">To Page</div></td>
					<td><input style="width: 100%;" class="nojs-SuggestBox" type="text" name="b" value="<%=pageB.replace("\"", "&#34;")%>"></td>
					</tr><tr>
					<td style="vertical-align: middle;" align="right"></td>
					<td style="vertical-align: middle;" align="left"><button class="nojs-Button" type="submit">Search</button></td>
					</tr>
					</tbody></table>
					</fieldset></form>
				</span>
			</div>
	
		</div>
			    
		<script type="text/javascript">
			function dataView() {
				var graph = document.getElementById('graph_data');
				graph.style.display = (graph.style.display == 'table') ? 'none' : 'table';
			}
			function popout(url) {
				if(window.wp===undefined || window.wp.closed){
					window.wp=window.open(url,'wikipop',
							'width=618,height=309,scrollbars=yes,menubar=no,status=no,toolbar=no,directories=no');
				} else {
					window.wp.location=url;
					window.wp.focus();
				}
				return false;
			}
		</script>

		<div id="query"><span class='noscript'>query: <%=query%> oquery: <%=oquery%> </span></div>
		<div id="results"><span class='noscript'>result: <%=result%></span></div>
				
		<div id="banner">
			<div id="sense">
				<script type="text/javascript">
					google_ad_client = "ca-pub-3243195690368203";
					google_ad_slot = "7753299005";
					google_ad_width = 728;
					google_ad_height = 90;
				</script>
				<!--<script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script>-->
			</div>
		</div>

		<script type="text/javascript">
			var _gaq = _gaq || [];
			_gaq.push(['_setAccount', 'UA-19094022-1']);
			(function() {
				var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
				ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
				var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
			})();
		</script>
				
		<div id="info">
			<p>
				<a target='_blank' href='http://blog.wiki-hop.org/'>blog</a> //
				<a target='_blank' href='http://wikimediafoundation.org/wiki/Donate?from=Wiki-Hop'>donate to wikipedia</a> //
				<a target='_blank' href='mailto:erik@wiki-hop.org'>contact</a>
			</p>
		</div>

	</body>
</html>
