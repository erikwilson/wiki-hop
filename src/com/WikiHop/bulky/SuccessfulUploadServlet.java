package com.WikiHop.bulky;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@SuppressWarnings("serial")
public class SuccessfulUploadServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		String blobKey = req.getParameter("blob-key");
		resp.setContentType("text/html");
		resp.getWriter().println("<p>File successfully uploaded.<br>");
		resp.getWriter().println("<a href='/bulky/serve?blob-key="+blobKey+"'>"+"download link</a></p>");
		resp.getWriter().println("<p><b>"+blobKey+"</b></p>");
		resp.getWriter().println("<p><b><a href='/mapreduce/status'>/mapreduce/status</a><b><br>");
		resp.getWriter().println("<iframe src='/mapreduce/status' width='100%' height='100%' frameborder='0'/></p>");
	}
}
