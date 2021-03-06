/*  Streamlined.js
 *  (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
 *
 *  Streamlined.js is freely distributable under the terms of an MIT-style license.
 *  For details, see http://streamlined.relevancellc.com
 */ 
if (typeof(Prototype) == "undefined") {
  throw ("Streamlined requires Prototype");
}
if (typeof(Streamlined) == "undefined") {
  Streamlined = {}
}
Streamlined.PageOptions = {
  form: function() {
    return $("page_options");
  },
  pageInput: function() {
    return this.form()["page_options[page]"];
  },
  counterInput: function() {
    return this.form()["page_options[counter]"];
  },
  poke: function() {
    this.counterInput().value = this.currentCounter() + 1
  },
  asCounter: function(input) {
    var val = parseInt(input.value);
    if (isNaN(val) || val < 0) {
      val = 1;
    }
    return val;
  },
  currentPage: function() {
    return this.asCounter(this.pageInput());
  },
  currentCounter: function() {
    return this.asCounter(this.counterInput());
  },
  nextPage: function() {
    return this.pageInput().value = this.currentPage()+1;
  },
  previousPage: function() {
    var val = this.currentPage()-1;
    if (val < 0) val = 0;
    return this.pageInput().value = val;
  }
};
Streamlined.FilterWatcher = {
	initialize: function() {
		if($('page_options'))
			new Form.Observer('page_options', 
								0.5, 
								function(element, value) {
									new Ajax.Updater(streamlined_model + '_list', '/' + streamlined_models + '/list', 
														{asynchronous:true, 
														 evalScripts:true, 
														 onComplete:function(request){
															Streamlined.SortSelector.initialize()
														 }, 
														parameters:value})});
			new PeriodicalExecuter(function() {
			    if($('streamlined_filter_term')) {
				    $('page_options_filter').value = $('streamlined_filter_term').value;
			    }
			}, 0.5);
			
	}
}
Streamlined.SortSelector = {
  sortColumn: function() {
    return Streamlined.PageOptions.form()["page_options[sort_column]"];
  },
  sortOrder: function() {
    return Streamlined.PageOptions.form()["page_options[sort_order]"];
  },
  selectorClass: 'sortSelector',
  initialize: function() {
    $$('.' + this.selectorClass).each((function(item) {
      text = item.innerHTML;
      item.innerHTML = "";
      item.appendChild(this.makeLink(text));
    }).bind(this));
  },
  makeLink: function(text) {
    var s = document.createElement("a");
    s.href = "javascript:void%200";
    s.onclick = (function() {
      this.updateForm(text.stripTags());
    }).bind(this);
    s.innerHTML = text;
    return s;
  },
  updateForm: function(text) {
    var column = this.sortColumn();
    column.value = text
    var order = this.sortOrder();
    order.value = (order.value == 'ASC' ? 'DESC' : 'ASC')
  }
};
Streamlined.Menu = {
  initialize: function() {
		navRoot = $("nav");
		if (navRoot) {
  		for (i=0; i<navRoot.childNodes.length; i++) {
  			node = navRoot.childNodes[i];
  			if (node.nodeName=="LI") {
  			  Event.observe(node, "mouseover", function() {
  			    Element.addClassName(this, "over");
  			  });
  			  Event.observe(node, "mouseout", function() {
  			    Element.removeClassName(this, "over");
  			  });
  			}
  		}
		}
  }
};
Event.observe(window, "load", function() {
  Streamlined.SortSelector.initialize();
  Streamlined.Menu.initialize();
  Streamlined.FilterWatcher.initialize();
  if ($('spinner')) {
	Ajax.Responders.register({
	  onCreate: function(request) {
  		$('spinner').show();
	  },
	  onComplete: function(request) {
  		if (Ajax.activeRequestCount == 0) {
  		  $('spinner').hide();
  		}
	  }
	});	
  }
});

Streamlined.Windows = {
	open_window: function(title_prefix, server_url, model) {
		if(model == null) {
			model = '00';
		}
		id = "show_win_" + model;
		if($(id)) {
		    return;
		}
		win2 = new Window(id, {
		  className: 'mac_os_x', 
		  title: title_prefix + " " + model, 
		  width:500, height:300, top:200, left: 200, 
		  zIndex:150, opacity:1, resizable: true, 
		  hideEffect: Effect.Fade,
		  url: server_url
		});
	  	win2.setDestroyOnClose();
	  	win2.show();		
	},
	
	open_local_window: function(title_prefix, content, model) {
	    id= "show_win_" + model;
	    if($(id)) {
	        return;
	    }
		win2 = new Window(id, {
		  className: 'mac_os_x', 
		  title: title_prefix + " " + model, 
		  width:500, height:300, top:200, left: 200, 
		  zIndex:150, opacity:1, resizable: true, 
		  hideEffect: Effect.Fade			
		});
		win2.getContent().innerHTML = content;
		win2.setDestroyOnClose();
		win2.show();
	},
	
	open_local_window_from_url: function(title_prefix, url, model) {
	        if (model == null) {
	            model = "new"
	        }
	        new Ajax.Request(url, {
			method: "get", 
			onComplete: function(request) {
			        Streamlined.Windows.open_local_window(title_prefix, request.responseText, model);
			}
		});
	}
}

Streamlined.Exporter = {
	export_to: function(url) {
			window.location = url + "?" + Form.serialize('page_options');
	}
}

Streamlined.Relationships = {
	open_relationship: function(id, link, url) {
		ids = id.split("::");
		rel_type = ids[0];
		rel_name = ids[1];
		item_id = ids[2];
		klass = ids[3];
        params = "id=" + item_id + "&relationship=" + rel_name + "&klass=" + klass + "&type=" + rel_type;
		if(rel_type == "Window") {
			new Ajax.Request(url + "/expand_relationship", {
				method: "get",
				parameters: params, 
				onComplete: Streamlined.Relationships.open_relationship_in_window
			});
		} else {
			new Ajax.Updater(id, url + "/expand_relationship", {
				evalScripts: true,
				parameters: params
			});
			if(rel_type == "rel_many")
				link.innerHTML = "-";
			else
				link.innerHTML = "Close";
			link.onclick = new Function("Streamlined.Relationships.close_relationship('" + id + "', this, '" + url + "')");	
		}
	},
	
	open_relationship_in_window: function(request) {
		Streamlined.Windows.open_local_window('', request.responseText, null);
	},

	close_relationship: function(id, link, url) {
		ids = id.split("::");
		rel_type = ids[0];
		rel_name = ids[1];
		item_id = ids[2];
		klass = ids[3];
		new Ajax.Updater(id, url + "/close_relationship", {
			parameters: "id=" + item_id + "&relationship=" + rel_name + "&klass=" + klass + "&type=" + rel_type
		})
		if(rel_type == "rel_many")
			link.innerHTML = "+";
		else
			link.innerHTML = "Edit";
		link.onclick = new Function("Streamlined.Relationships.open_relationship('" + id + "', this, '" + url + "')");
	}
}

Streamlined.Popup = {
    show: function(url) {
        new Ajax.Request(url,{ onSuccess: function(xhr) {return overlib(xhr.responseText);}})
    }
}

Streamlined.Form = {
    toggle_field: function(field) {
        if($(field).disabled != '') {
            $(field).disabled = '';
            Field.activate($(field));
        } else {
            $(field).disabled = "true";
        }
    }
}