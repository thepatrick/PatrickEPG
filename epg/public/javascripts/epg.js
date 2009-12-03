Date.prototype.setISO8601 = function(dString){

   var regexp = /(\d\d\d\d)(-)?(\d\d)(-)?(\d\d)(T)?(\d\d)(:)?(\d\d)(:)?(\d\d)(\.\d+)?(Z|([+-])(\d\d)(:)?(\d\d))/;

   if (dString.toString().match(new RegExp(regexp))) {
      var d = dString.match(new RegExp(regexp));
      var offset = 0;
			
      this.setUTCFullYear(parseInt(d[1]));
      this.setUTCMonth(d[3] - 1);
      this.setUTCDate(d[5]);
      this.setUTCHours(d[7]);
      this.setUTCMinutes(d[9]);
      this.setUTCSeconds(d[11]);
      if (d[12])
         this.setUTCMilliseconds(parseFloat(d[12]) * 1000);
      else
         this.setUTCMilliseconds(0);
      if (d[13] != 'Z') {
         offset = (d[15] * 60) + parseInt(d[17]);
         offset *= ((d[14] == '-') ? -1 : 1);
         this.setTime(this.getTime() - offset * 60 * 1000);
      }
   }
   else {
      this.setTime(Date.parse(dString));
   }
   return this;
};

Date.prototype.ourStyle = function() {
	return this.strftime('%A %B %e, %H:%M');
}

Date.prototype.iso8601 = function() {
	return this.UTCstrftime('%Y-%m-%dT%H:%M:%SZ');
}

Date.dateWithISO8601 = function(isoDate,f) {
	new_date = new Date(0);
	new_date.setISO8601(isoDate);
	return new_date;
}

/* PDTable, v1.1 (now works in IE!)
 * Copyright (c) 2006 Patrick Quinn-Graham
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

var PDTable = Class.create({
	options : {
		sticky : [],
		skeletons : [],
		defaultskeleton : 0,
		table : null,
		rowTag : 'TR',
		cellTag : 'TD'
	}, 
	initialize: function(options) {
		if(Object.isString(options.skeleton) || Object.isElement(options.skeleton)) {
			options.skeletons = [options.skeleton] ;
		}
		options.skeletons.each(function(a){
			$(a).style.display = 'none';
			options.sticky[options.sticky.length] = a;
		});
		Object.extend(this.options, options || {});
	},
	clear: function() {
		$A($(this.options.table).getElementsByTagName(this.options.rowTag)).each(function(a){
			test = 1;
			$A(this.options.sticky).each(function(b){ 
				if(a.id == b) {
					test = 0;
				}
			});
			if(test)
				$(a).remove();
		}.bind(this));
	},
	addRow: function(opts) {
		if(!opts) return false; /*Can't really do anything.*/
		if(!opts.skeleton)
			opts.skeleton = this.options.defaultskeleton;
		r = $(this.options.skeletons[opts.skeleton]).cloneNode(true);
		r.id = opts.id;
		r.style.display = '';
		if($(this.options.table).firstChild.nodeName == "TBODY") {
			out = $(this.options.table).firstChild;
		} else {
			out = $(this.options.table);
		}
		out.appendChild(r);
		

		$A(r.getElementsByTagName(this.options.cellTag)).each(function(td) {
			if(td.className.indexOf(' ') != -1) {
				className = td.className.substring(0, td.className.indexOf(' '));
			} else {
				className = td.className;
			}
			b = className.substring(className.indexOf('-') + 1);
			if(opts.values[b])
				td.firstChild.nodeValue = opts.values[b];
		});
		if(opts.callback) {
			opts.callback(r);
		}
		
		return r;
	},
	addMulti: function(values, opts) {
		if(!opts) return false;
		if($type(values) != "array") return false;
		values.each(function(v, i){
			this.addRow({ id: opts.id + "-" + i, values: v, callback: opts.callback })
		}.bind(this));
	}
});

var patrickScroller = {
	currentOffset: 0,
	multiplier: 1,
	otherTimesController: null,
	zeroTime: null,
	
	setup: function() {
		$('epg-times-move-left').onclick = function() { this.jump(-60); return false; }.bind(this);
		$('epg-times-move-right').onclick = function() { this.jump(60	); return false; }.bind(this);

		this.otherTimesController = new PDTable({table: 'epg-popup-othertimes', 
			skeleton: 'epg-popup-othertimes-skeleton', 
			sticky: ['epg-popup-othertimes-header', 'epg-popup-othertimes-skeleton']});
			
		this.loadMoreData(23);
	},
	
	setZeroTime: function(dateStr) {
		this.zeroTime = Date.dateWithISO8601(dateStr);
	},
	
	jump: function(by) {
		this.currentOffset = this.currentOffset + by;
		$('epg-times-inner').style.marginLeft='-' + (this.currentOffset * this.multiplier) + 'px';
		
		$$('.epg-channel-shows-inner').each(function(a){
			$(a).setStyle({marginLeft: '-' + (this.currentOffset * this.multiplier) + 'px'});
		}.bind(this));
	},
	
	updateOrHide: function(el, value) {
		if(value) {
			$(el).update(value).show();
		} else {
			$(el).hide();
		}
	},
	
	showIfTrue: function(el, value) {
		if(value) {
			$(el).show();
		} else {
			$(el).hide();					
		}
	},
	
	showInfo: function(scheduleId) {		
		new Ajax.Request("/epg-data/" + scheduleId + "/ShowInformation.json", {
			method: 'get',
			onComplete: function(t) {
				r = t.responseJSON;
				$('epg-popup-showName').update(r.program.program.title);
				
				this.updateOrHide('epg-popup-subtitle', r.program.program.subtitle);
				this.updateOrHide('epg-popup-description', r.program.program.description);
				this.updateOrHide('epg-popup-time-episode', r.program.program.syndicated_episode_number);
				
				this.showIfTrue('epg-popup-hdtv', r.schedule.schedule.hdtv);
				this.showIfTrue('epg-popup-new', r.schedule.schedule.first_run);
				this.showIfTrue('epg-popup-dolby', r.schedule.schedule.dolby);
		
				$(this.otherTimesController.options.table).hide();
				$('epg-popup').show();
				
				start_time = Date.dateWithISO8601(r.schedule.schedule.start_time);
				$('epg-popup-time-start').update(start_time.ourStyle());
				$('epg-popup-time-duration').update(r.schedule.schedule.duration + " mins");
				
				$('epg-popup-findOthers').onclick = function() {
					this.otherTimes(scheduleId);
				}.bind(this);
				
				if(r.recording) {
					$('epg-popup-record').addClassName('recording');
					$('epg-popup-record').onclick = function() {
						this.cancelRecording(r.recording.recording.id);
					}.bind(this);
				} else {
					$('epg-popup-record').removeClassName('recording');
					$('epg-popup-record').onclick = function() {
						this.recordMe(scheduleId);
					}.bind(this);		
				}
 				
				
				
			}.bind(this)
		});
		
	},
	
	otherTimes: function(scheduleId) {
		new Ajax.Request("/epg-data/" + scheduleId + "/OtherTimes.json", {
			method: 'get',
			onComplete: function(t) {
				r = t.responseJSON;
				
				this.otherTimesController.clear();
				
				$(this.otherTimesController.options.table).show();
				
				//this._stations = r.stations;
				
				$A(r.times).each(function(s, idx){
					marf = this.otherTimesController.addRow({
							'id': 'othertimes-' + idx,
							'values': {
								'when':  Date.dateWithISO8601(s.when).ourStyle(),
								'on': s.on,
								'hdtv': (s.hdtv ? "YES" : "NO")
							}
						});
				}.bind(this));
			}.bind(this)
		});
	},
	
	recordMe: function(scheduleId) {
		new Ajax.Request("/PVR/Schedule.json", {
			method: 'get',
			parameters: {'id': scheduleId },
			onComplete: function(t) {
				r = t.responseJSON;
				
				if(!r || !r.success) {
					alert('Failed to set recording.');
					return;
				}
 				
				$$(".epg-show-program-" + r.recording.program_id).each(function(a){
					a.addClassName('show-record');
				});
				
				$('epg-popup-record').addClassName('recording');
				$('epg-popup-record').onclick = function() {
					this.cancelRecording(r.recording.id);
				}.bind(this);
				
			}.bind(this)
		});
	},

	cancelRecording: function(recording_id) {
			new Ajax.Request("/PVR/Delete.json", {
				method: 'get',
				parameters: {'id': recording_id },
				onComplete: function(t) {
					r = t.responseJSON;

					if(!r || !r.success) {
						alert('Failed to delete recording.');
						return;
					}
					
					e = ".epg-show-program-" + r.recording.recording.program_id;					
					$$(e).each(function(a){
						a.removeClassName('show-record');
					});
					
				
					$('epg-popup-record').removeClassName('recording');
					$('epg-popup-record').onclick = function() {
						this.recordMe(r.recording.recording.schedule_id);
					}.bind(this);

				}.bind(this)
			});
	},
	
	addTimeGuide: function(d) {
		el = new Element('div', {'class': 'epg-time'});
		el.update(d.strftime("%I:%M %p"));
		$('epg-times-inner').appendChild(el);
	},
	
	makeShowHTML: function(s) {
		show_el = new Element('div', {'class': 'epg-channel-show-inside'});
		show_el.update(s.show_name);
		
		show_container_el = new Element('div', {'class': 'epg-channel-show'});
		
		show_container_el.addClassName('epg-show-program-' + s.program);
		show_container_el.addClassName('epg-show-sched-' + s.id);
		
		if(s.show_name == "") {
			show_container_el.addClassName('show-blank');
		}
		if(s.hdtv) {
			show_container_el.addClassName('show-hdtv');
		}
		if(s.first_run) {
			show_container_el.addClassName('show-firstrun');
		}
		if(s.recording) {
			show_container_el.addClassName('show-record');
		}
			
		//width = (sch.duration * time_multiplier) + (width_adjuster * time_multiplier)
		
		width = s.duration * this.multiplier;
		
		show_container_el.setStyle({
					'float': 'left',
					'margin-left': 0,
					'width': (width - 21) + 'px',
					'padding-left': '10px',
				});
		
		show_container_el.appendChild(show_el);
		
		show_container_el.onclick = function(){ this.showInfo(s.id); }.bind(this); 
		
		return show_container_el;
	},
	
	loadMoreData: function(hours) {
			new Ajax.Request("/Data.json", {
				method: 'get',
				parameters: { 'hours': hours,  'start': this.zeroTime.iso8601() },
				onComplete: function(t) {
					r = t.responseJSON;
				
					$A(r.display_times).each(function(s){
						this.addTimeGuide(Date.dateWithISO8601(s));						
					}.bind(this));
					
					$A(r.programs).each(function(ch){
						this_channel = $('epg-channel-' + ch.channel);
						this_channel_inner = this_channel.select('.epg-channel-shows-inner')[0];
												
						$A(ch.programs).each(function(show){
							// alert(show);
							this_channel_inner.appendChild(this.makeShowHTML(show));
						}.bind(this));
						
					}.bind(this));
										
				}.bind(this)
			});
		
	}
}