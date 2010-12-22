package com.WikiHop.bulky;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;

@SuppressWarnings("serial")
public class UploadBlobServlet extends HttpServlet {
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
		BlobKey blobKey = blobstoreService.getUploads(req).get("data").get(0);
		if (blobKey == null) {
			resp.sendRedirect("/bulky/failed.jsp");
		} else {
			resp.sendRedirect("/bulky/success?blob-key=" + blobKey.getKeyString());
		}
	}
}
