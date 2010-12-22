package com.WikiHop.client;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.HashMap;

import com.google.gwt.http.client.URL;
import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.dom.client.FocusEvent;
import com.google.gwt.event.dom.client.FocusHandler;
import com.google.gwt.event.dom.client.KeyCodes;
import com.google.gwt.event.dom.client.KeyDownEvent;
import com.google.gwt.event.dom.client.KeyDownHandler;
import com.google.gwt.event.dom.client.KeyUpEvent;
import com.google.gwt.event.dom.client.KeyUpHandler;
import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.event.logical.shared.ValueChangeHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.MultiWordSuggestOracle;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.SuggestBox;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.CaptionPanel;
import com.google.gwt.user.client.ui.SuggestOracle;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.SuggestBox.DefaultSuggestionDisplay;


public class WikiHopPath implements EntryPoint, ValueChangeHandler<String> {
	
	private final SearchPathAsync searchPath = GWT.create(SearchPath.class);
	private final WordOracleAsync wordOracle = GWT.create(WordOracle.class);
	WikiOracle oracle;
    SuggestBox fromPageBox, toPageBox;
    Button swapButton, submitButton;
    HTML serverResponseLabel;
    RootPanel results;
    HTML socialLinks;
    SearchHandler search;

	boolean history_onload = true;

	public WikiHopPath()
    {
        oracle = new WikiOracle();
        fromPageBox = new SuggestBox(oracle);
        toPageBox = new SuggestBox(oracle);
        submitButton = new Button("Search");
        swapButton = new Button("Swap");
        serverResponseLabel = new HTML();
        results = RootPanel.get("results");
        socialLinks = new HTML();
        search = new SearchHandler();
    }
	
	public void onValueChange(ValueChangeEvent<String> event) {
		String anchor = event.getValue().trim();
		if (anchor.matches("^.*//.*")) {
			String[] p = anchor.split("//",-1);
			if (p.length==2) {
				if ("!".equals(p[0].substring(0,1))) p[0] = p[0].substring(1,p[0].length());
				if ("/".equals(p[0].substring(0,1))) p[0] = p[0].substring(1,p[0].length());
				p[0] = p[0].replace("\\/\\/\\","//").replace("_"," ").trim();
				p[1] = p[1].replace("\\/\\/\\","//").replace("_"," ").trim();
				
				fromPageBox.setText(p[0]);
				toPageBox.setText(p[1]);

				serverResponseLabel.removeStyleName("serverResponseLabelError");
				serverResponseLabel.setHTML("searching...");
				Window.setTitle("Wiki-Hop: "+p[0]+" // "+p[1]);
				search.setPage(p[0],p[1]);
				/*
				if (!history_onload) {
					try {
						Node refresh = RootPanel.get("refresh").getElement();
						Node newRefresh = refresh.cloneNode(true);
						Node parent = refresh.getParentElement();
						parent.removeChild(refresh);
						parent.appendChild(newRefresh);
					} catch (Exception e) {}
				} else {
					history_onload = false;
				}
				*/
				
				searchPath.find(p[0],p[1],
						new AsyncCallback<String>() {
							public void onFailure(Throwable caught) {
								serverResponseLabel.addStyleName("serverResponseLabelError");
								serverResponseLabel.setHTML(caught.getMessage());
								swapButton.setEnabled(true);
								submitButton.setEnabled(true);
							}

							public void onSuccess(String result) {
								serverResponseLabel.setHTML(result);
								swapButton.setEnabled(true);
								submitButton.setEnabled(true);
							}
						});
			}
		} else {
			swapButton.setEnabled(true);
			submitButton.setEnabled(true);
            serverResponseLabel.removeStyleName("serverResponseLabelError");
            search.setPage("", "");
            results.remove(serverResponseLabel);
            serverResponseLabel = new HTML("<div id='welcome'><table style='width: 100%'><tbody><tr><td>"+
            		"<a href='http://www.wiki-hop.org/#!/Paul_Erd%C5%91s//Kevin_Bacon'><img src='/sample.png' /></a></td>"+
            		"<td style='font-size:1.618em;'><h2>Welcome to Wiki-Hop!</h2>"+
            		"<p>Begin by searching for names of people in Wikipedia... </p>"+
            		"<p><b><i>Example Search:</i></b> <a href='http://www.wiki-hop.org/#!/Paul_Erd%C5%91s//Kevin_Bacon'>Paul Erd\u0151s to Kevin Bacon</a></p>"+
            		"<p><span id='readmore'>(<a href='http://blog.wiki-hop.org/2010/12/six-degrees.html' target='_blank'>more about wiki-hop</a>)</span></p></td></tr></tbody></table></div>");
            results.add(serverResponseLabel);
			fromPageBox.setFocus(true);
		}
	}

	
	class WikiOracle extends MultiWordSuggestOracle {
		private HashMap<String,SuggestOracle.Response> history = new HashMap<String,SuggestOracle.Response>();		
		private String current = null;
		private Timer keyWatch = null;
		
		public void seer(final String s, final SuggestOracle.Request request, final SuggestOracle.Callback callback) {
			if (!s.equals(getCurrentSearch())) return;
			
			if (s.isEmpty()) {
				callback.onSuggestionsReady(request, new SuggestOracle.Response());
			} else if (history.containsKey(s)) {
				callback.onSuggestionsReady(request, history.get(s));
			} else {
				wordOracle.seer(s, new AsyncCallback<Collection<String>>() {
					public void onFailure(Throwable caught) {}
					public void onSuccess(Collection<String> result) {
						List<MultiWordSuggestion> mws = new ArrayList<MultiWordSuggestion>();
						for (String r:result) {
							int p = r.toLowerCase().indexOf(s);
							String b = r.substring(0,p)
							+  "<b>" + r.substring(p,p+s.length()) + "</b>" 
							+          r.substring(p+s.length(),r.length());
							mws.add(new MultiWordSuggestion(r,b));					
						}
						SuggestOracle.Response response = new SuggestOracle.Response(mws);
						history.put(s,response);
						if (s.equals(getCurrentSearch())) callback.onSuggestionsReady(request, response);
					}
				});
			}
		}
		
		public void requestSuggestions(final SuggestOracle.Request request, final SuggestOracle.Callback callback) {
			String r = request.getQuery().trim().toLowerCase();
			final String s = (r.length()<2?"":r);
			setCurrentSearch(s);
			if (keyWatch != null) keyWatch.cancel();
			keyWatch = new Timer() { @Override public void run() { seer(s,request,callback); } };
			keyWatch.schedule(200);
		}
		
		public boolean isDisplayStringHTML() { return true; }
		public void setCurrentSearch(String current) { this.current = current; }
		public String getCurrentSearch() { return current; }
	}


	class SearchHandler implements ClickHandler, KeyUpHandler, KeyDownHandler, FocusHandler {

		public void onClick(ClickEvent event) { update(); }

		public void onKeyUp(KeyUpEvent event) 
		{ if (event.getNativeKeyCode() == KeyCodes.KEY_ENTER) update(); }

		public void onKeyDown(KeyDownEvent event) 
		{ if (event.getNativeKeyCode() == KeyCodes.KEY_TAB) update(); }

		public void onFocus(FocusEvent event) {	update(); }

		private String a, b;
		
		public void update() {
			String x = fromPageBox.getText().trim();
			String y = toPageBox.getText().trim();
			if (!(x.equals(a) && y.equals(b))) {
				if (x.equals("")) {
					fromPageBox.setFocus(true);
				} else if (y.equals("")) {
					toPageBox.setFocus(true);
				} else {
					wikiHopSearchRequest(x,y);
				}
			}
		}

		public void setPage(String x, String y) { a=x; b=y; }
		
        public void wikiHopSearchRequest(String x, String y)
        {
            try
            {
                swapButton.setEnabled(false);
                submitButton.setEnabled(false);
                String pageA = x.replace("//", "\\/\\/\\").replace(" ", "_");
                String pageB = y.replace("//", "\\/\\/\\").replace(" ", "_");
                History.newItem("!/"+pageA+"//"+pageB);
            }
            catch(Exception e)
            {
                swapButton.setEnabled(true);
                submitButton.setEnabled(true);
                serverResponseLabel.addStyleName("serverResponseLabelError");
                serverResponseLabel.setHTML("Unable to parse fields: "+e.toString());
            }
        }
	}
	
	class Swapper implements ClickHandler {
		SearchHandler handler;
		public Swapper(SearchHandler h) { handler = h; }
		public void onClick(ClickEvent event) {
			String f = fromPageBox.getText();
			fromPageBox.setText(toPageBox.getText());
			toPageBox.setText(f);
			handler.update();
		}
	}

	public void onModuleLoad() {
		
        String query = URL.decode(Window.Location.getQueryString()).replace("%2F", "/");
        
        if(query.matches("^\\?!?/.*"))
            Window.Location.replace(Window.Location.getPath()+
            		query.replaceFirst("^\\?!?", "#!"));
        else
        if(query.indexOf("?_escaped_fragment_=") == 0)
            Window.Location.replace(Window.Location.getPath()+
            		query.replaceFirst("^\\?_escaped_fragment_=", "#!"));
        else
        if(query.indexOf("?a=") == 0)
            Window.Location.replace(Window.Location.getPath()+
            		query.replaceFirst("^\\?a=", "#!/").replaceFirst("&b=", "//").replaceAll("\\+", "_"));
        
		CaptionPanel searchPanel = new CaptionPanel("Search for People in Wikipedia.org");
		searchPanel.setWidth("35em");	
		
		Label fromPageLabel = new Label("From Page");
		Label toPageLabel = new Label("To Page");
		fromPageLabel.setHorizontalAlignment(HasHorizontalAlignment.ALIGN_RIGHT);
		toPageLabel.setHorizontalAlignment(HasHorizontalAlignment.ALIGN_RIGHT);
		fromPageLabel.setWordWrap(false);
		toPageLabel.setWordWrap(false);
		fromPageBox.setWidth("100%");
		toPageBox.setWidth("100%");
		DefaultSuggestionDisplay fromDisplay = (DefaultSuggestionDisplay)fromPageBox.getSuggestionDisplay();
		DefaultSuggestionDisplay toDisplay = (DefaultSuggestionDisplay)toPageBox.getSuggestionDisplay();
		fromDisplay.setPopupStyleName("gwt-SuggestBoxPopup-wiki");
		toDisplay.setPopupStyleName("gwt-SuggestBoxPopup-wiki");

		fromPageBox.addKeyUpHandler(search);
		toPageBox.addKeyUpHandler(search);
		swapButton.addClickHandler(new Swapper(search));
		submitButton.addClickHandler(search);
		submitButton.addFocusHandler(search);
		
		FlexTable flexTable = new FlexTable();
		searchPanel.setContentWidget(flexTable);
		flexTable.setWidth("100%");

		flexTable.getCellFormatter().setHorizontalAlignment(2, 0, HasHorizontalAlignment.ALIGN_RIGHT);
		flexTable.getCellFormatter().setHorizontalAlignment(2, 1, HasHorizontalAlignment.ALIGN_LEFT);
		flexTable.getCellFormatter().setVerticalAlignment(2, 0, HasVerticalAlignment.ALIGN_MIDDLE);
		flexTable.getCellFormatter().setVerticalAlignment(2, 1, HasVerticalAlignment.ALIGN_MIDDLE);

		flexTable.setWidget(0, 0, fromPageLabel);
		flexTable.setWidget(0, 1, fromPageBox);
		flexTable.setWidget(1, 0, toPageLabel);
		flexTable.setWidget(1, 1, toPageBox);
		flexTable.setWidget(2, 0, swapButton);
		flexTable.setWidget(2, 1, submitButton);
		
		fromPageBox.setTabIndex(1);
		toPageBox.setTabIndex(2);
		submitButton.setTabIndex(3);

		RootPanel rootPanel = RootPanel.get("wikiHopPath");
		rootPanel.add(searchPanel, 0, 0);
		results.add(serverResponseLabel);
		History.addValueChangeHandler(this);
		History.fireCurrentHistoryState();
	}
}
