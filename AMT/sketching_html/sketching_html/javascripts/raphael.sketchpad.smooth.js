/*
 * Raphael SketchPad
 * Version 0.5
 * Copyright (c) 2010 Ian Li (http://ianli.com)
 * Licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) license.
 * 
 * Modified by Mathias Eitz (m.eitz@tu-berlin.de) to support smoother lines.
 * This is achieved by first simplifying lines using the Douglas-Peucker algorithm
 * and the smoothing lines by representing them as cubic Bezier segments with G1
 * continuity at vertices.
 *
 * Requires:
 * jQuery	http://jquery.com
 * Raphael	http://raphaeljs.com
 * JSON		http://www.json.org/js.html
 *
 * Reference:
 * http://ianli.com/sketchpad/ for Usage
 * 
 * Versions:
 * 0.5 - Added freeze_history. Fixed bug with undoing erase actions.
 * 0.4 - Support undo/redo of strokes, erase, and clear.
 *     - Removed input option. To make editors/viewers, set editing option to true/false, respectively.
 *       To update an input field, listen to change event and update input field with json function.
 *     - Reduce file size V1. Changed stored path info from array into a string in SVG format.
 * 0.3 - Added erase, supported initializing data from input field.
 * 0.2 - Added iPhone/iPod Touch support, onchange event, animate.
 * 0.1 - Started code.
 *
 * TODO:
 * - Speed up performance.
 *   - Don't store strokes in two places. _strokes and ActionHistory.current_strokes()
 *	 - Don't rebuild strokes from history with ActionHistory.current_strokes()
 * - Reduce file size.
 *   X V1. Changed stored path info from array into a string in SVG format.
 */

/**
 * We use this wrapper to control global variables.
 * The only global variable we expose is Raphael.sketchpad.
 */
(function(Raphael) {
	
	/**
	 * Function to create SketchPad object.
	 */
	Raphael.sketchpad = function(paper, options) {
		return new SketchPad(paper, options);
	}
	
	// Current version.
	Raphael.sketchpad.VERSION = 0.5;
	
	/**
	 * The Sketchpad object.
	 */
	var SketchPad = function(paper, options) {
		// Use self to reduce confusion about this.
		var self = this;
		
		var _options = {
			width: 100,
			height: 100,
			strokes: [],
			editing: true
		};
		jQuery.extend(_options, options);
		
		
		// The Raphael context to draw on.
		var _paper;
		if (paper.raphael && paper.raphael.constructor == Raphael.constructor) {
			_paper = paper;
		} else if (typeof paper == "string") {
			_paper = Raphael(paper, _options.width, _options.height);
		} else {
			throw "first argument must be a Raphael object, an element ID, an array with 3 elements";
		}
		
		// The Raphael SVG canvas.
		var _canvas = _paper.canvas;

		// The HTML element that contains the canvas.
		var _container = $(_canvas).parent();

		// The default pen.
		var _pen = new Pen();
		
		
		// Public Methods
		//-----------------
		
		self.paper = function() {
			return _paper;
		};
		
		self.canvas = function() {
			return _canvas;
		};
		
		self.container = function() {
			return _container;
		};
		
		self.pen = function(value) {
			if (value === undefined) {
				return _pen;
			}
			_pen = value;
			return self; // function-chaining
		};
		
		// Convert an SVG path into a string, so that it's smaller when JSONified.
		// This function is used by json().
		/*
		function svg_path_to_string(path) {
			var str = "";
			for (var i = 0, n = path.length; i < n; i++) {
				var point = path[i];
				str += point[0] + point[1] + "," + point[2];
			}
			return str;
		}
		*/
		
		/*
		// Convert a string into an SVG path. This reverses the above code.
		function string_to_svg_path(str) {
			var path = [];
			var tokens = str.split("L");
			
			if (tokens.length > 0) {
				var token = tokens[0].replace("M", "");
				var points = token.split(",");
				path.push(["M", parseInt(points[0]), parseInt(points[1])]);
				
				for (var i = 1, n = tokens.length; i < n; i++) {
					token = tokens[i];
					points = token.split(",");
					path.push(["L", parseInt(points[0]), parseInt(points[1])]);
				}
			}
			
			return path;
		}
		*/
		
		self.json = function(value) {
			if (value === undefined) {
		
				/*
				for (var i = 0, n = _strokes.length; i < n; i++) {
					var stroke = _strokes[i];
					if (typeof stroke.path == "object") {
						stroke.path = svg_path_to_string(stroke.path);
					}
				}
				*/
				return JSON.stringify(_strokes);		
			}
			
			return self.strokes(JSON.parse(value));
		};
		
		self.strokes = function(value) {
			if (value === undefined) {
				return _strokes;
			}
			if (jQuery.isArray(value)) {
				_strokes = value;
				
				/*
				for (var i = 0, n = _strokes.length; i < n; i++) {
					var stroke = _strokes[i];
					if (typeof stroke.path == "string") {
						stroke.path = string_to_svg_path(stroke.path);
					}
				}
				*/
				
				_action_history.add({
					type: "batch",
					strokes: jQuery.merge([], _strokes) // Make a copy.
				})
				
				_redraw_strokes();
				_fire_change();
			}
			return self; // function-chaining
		}
		
		self.freeze_history = function() {
			_action_history.freeze();
		};
		
		self.undoable = function() {
			return _action_history.undoable();
		};

		self.undo = function() {
			if (_action_history.undoable()) {
				_action_history.undo();
				_strokes = _action_history.current_strokes();
				_redraw_strokes();
				_fire_change();
			}
			return self; // function-chaining
		};

		self.redoable = function() {
			return _action_history.redoable();
		};

		self.redo = function() {
			if (_action_history.redoable()) {
				_action_history.redo();
				_strokes = _action_history.current_strokes();
				_redraw_strokes();
				_fire_change();
			}
			return self; // function-chaining
		};
		
		self.clear = function() {
			_action_history.add({
				type: "clear"
			});
			
			_strokes = [];
			_redraw_strokes();
			_fire_change();
			
			return self; // function-chaining
		};
		
		self.animate = function(ms) {
			if (ms === undefined) {
				ms = 500;
			}
			
			_paper.clear();
			
			if (_strokes.length > 0) {
				var i = 0;

				function animate() {
					var stroke = _strokes[i];
					var type = stroke.type;
					_paper[type]()
						.attr(stroke)
						.click(_pathclick);

					i++;
					if (i < _strokes.length) {
						setTimeout(animate, ms);
					}
				};

				animate();
			}
			
			return self; // function-chaining
		};
		
		self.editing = function(mode) {
			if (mode === undefined) {
				return _options.editing;
			}
			
			_options.editing = mode;
			if (_options.editing) {
				if (_options.editing == "erase") {
					// Cursor is crosshair, so it looks like we can do something.
					$(_container).css("cursor", "crosshair");
					$(_container).unbind("mousedown", _mousedown);
					$(_container).unbind("mousemove", _mousemove);
					$(_container).unbind("mouseup", _mouseup);
					$(document).unbind("mouseup", _mouseup);

					// iPhone Events
					var agent = navigator.userAgent;
					if (agent.indexOf("iPhone") > 0 || agent.indexOf("iPod") > 0) {
						$(_container).unbind("touchstart", _touchstart);
						$(_container).unbind("touchmove", _touchmove);
						$(_container).unbind("touchend", _touchend);
					}
				} else {
					// Cursor is crosshair, so it looks like we can do something.
					$(_container).css("cursor", "crosshair");

					$(_container).mousedown(_mousedown);
					$(_container).mousemove(_mousemove);
					$(_container).mouseup(_mouseup);

					// Handle the case when the mouse is released outside the canvas.
					$(document).mouseup(_mouseup);

					// iPhone Events
					var agent = navigator.userAgent;
					if (agent.indexOf("iPhone") > 0 || agent.indexOf("iPod") > 0) {
						$(_container).bind("touchstart", _touchstart);
						$(_container).bind("touchmove", _touchmove);
						$(_container).bind("touchend", _touchend);
					}
				}
			} else {
				// Reverse the settings above.
				$(_container).attr("style", "cursor:default");
				$(_container).unbind("mousedown", _mousedown);
				$(_container).unbind("mousemove", _mousemove);
				$(_container).unbind("mouseup", _mouseup);
				$(document).unbind("mouseup", _mouseup);
				
				// iPhone Events
				var agent = navigator.userAgent;
				if (agent.indexOf("iPhone") > 0 || agent.indexOf("iPod") > 0) {
					$(_container).unbind("touchstart", _touchstart);
					$(_container).unbind("touchmove", _touchmove);
					$(_container).unbind("touchend", _touchend);
				}
			}
			
			return self; // function-chaining
		}
		
		// Change events
		//----------------
		
		var _change_fn = function() {};
		self.change = function(fn) {
			if (fn == null || fn === undefined) {
				_change_fn = function() {};
			} else if (typeof fn == "function") {
				_change_fn = fn;
			}
		};
		
		function _fire_change() {
			_change_fn();
		};
		
		// Miscellaneous methods
		//------------------
		
		function _redraw_strokes() {
			_paper.clear();
			
			for (var i = 0, n = _strokes.length; i < n; i++) {
				var stroke = _strokes[i];
				var type = stroke.type;
				_paper[type]()
					.attr(stroke)
					/*.click(_pathclick);*/
			}
		};
		
		function _disable_user_select() {
			$("*").css("-webkit-user-select", "none");
			$("*").css("-moz-user-select", "none");
			if (jQuery.browser.msie) {
				$("editor").attr("onselectstart", "return false;");
			}
		}
		
		function _enable_user_select() {
			$("*").css("-webkit-user-select", "text");
			$("*").css("-moz-user-select", "text");
			if (jQuery.browser.msie) {
				$("editor").removeAttr("onselectstart");
			}
		}
		
		// Event handlers
		//-----------------
		// We can only attach events to the container, so do it.
		
		function _pathclick(e) {
			if (_options.editing == "erase") {
				var stroke = this.attr();
				stroke.type = this.type;
				
				_action_history.add({
					type: "erase",
					stroke: stroke
				});
				
				for (var i = 0, n = _strokes.length; i < n; i++) {
					var s = _strokes[i];
					if (equiv(s, stroke)) {
						_strokes.splice(i, 1);
					}
				}
				
				_fire_change();
				
				this.remove();
			}
		};
		
		function _mousedown(e) {
			_disable_user_select();

			_pen.start(e, self);
		};

		function _mousemove(e) {
			_pen.move(e, self);
		};

		function _mouseup(e) {
			_enable_user_select();
			
			//console.log('mouseup');
			
			var path = _pen.finish(e, self);
			
			if (path != null) {
				// Add event when clicked.
				path.click(_pathclick);
				
				// Save the stroke.
				var stroke = path.attr();
				stroke.type = path.type;
				
				_strokes.push(stroke);
				
				_action_history.add({
					type: "stroke",
					stroke: stroke
				});
				
				_fire_change();
			}
		};
		
		function _touchstart(e) {
			e = e.originalEvent;
			e.preventDefault();

			if (e.touches.length == 1) {
				var touch = e.touches[0];
				_mousedown(touch);
			}
		}
		
		function _touchmove(e) {
			e = e.originalEvent;
			e.preventDefault();

			if (e.touches.length == 1) {
				var touch = e.touches[0];
				_mousemove(touch);
			}
		}
		
		function _touchend(e) {
			e = e.originalEvent;
			e.preventDefault();

			_mouseup(e);
		}
		
		// Setup
		//--------
		
		var _action_history = new ActionHistory();
		
		// Path data
		var _strokes = _options.strokes;
		if (jQuery.isArray(_strokes) && _strokes.length > 0) {
			_action_history.add({
				type: "init",
				strokes: jQuery.merge([], _strokes)	// Make a clone.
			});
			_redraw_strokes();
		} else {
			_strokes = [];
			_redraw_strokes();
		}
		
		self.editing(_options.editing);
	};
	
	var ActionHistory = function() {
		var self = this;
		
		var _history = [];
		
		// Index of the last state.
		var _current_state = -1;
		
		// Index of the freeze state.
		// The freeze state is the state where actions cannot be undone.
		var _freeze_state = -1;
		
		// The current set of strokes if strokes were to be rebuilt from history.
		// Set to null to force refresh.
		var _current_strokes = null;
		
		self.add = function(action) {
			if (_current_state + 1 < _history.length) {
				_history.splice(_current_state + 1, _history.length - (_current_state + 1));
			}
			
			_history.push(action);
			_current_state = _history.length - 1;
			
			// Reset current strokes.
			_current_strokes = null;
		};
		
		self.freeze = function(index) {
			if (index === undefined) {
				_freeze_state = _current_state;
			} else {
				_freeze_state = index;
			}
		};
		
		self.undoable = function() {
			return (_current_state > -1 && _current_state > _freeze_state);
		};
		
		self.undo = function() {
			if (self.undoable()) {
				_current_state--;
				
				// Reset current strokes.
				_current_strokes = null;
			}
		};
		
		self.redoable = function() {
			return _current_state < _history.length - 1;
		};
		
		self.redo = function() {
			if (self.redoable()) {
				_current_state++;
				
				// Reset current strokes.
				_current_strokes = null;
			}
		};
		
		// Rebuild the strokes from history.
		self.current_strokes = function() {
			if (_current_strokes == null) {
				var strokes = [];
				for (var i = 0; i <= _current_state; i++) {
					var action = _history[i];
					switch(action.type) {
						case "init":
						case "json":
						case "strokes":
						case "batch":
							jQuery.merge(strokes, action.strokes);
							break;
						case "stroke":
							strokes.push(action.stroke);
							break;
						case "erase":
							for (var s = 0, n = strokes.length; s < n; s++) {
								var stroke = strokes[s];
								if (equiv(stroke, action.stroke)) {
									strokes.splice(s, 1);
								}
							}
							break;
						case "clear":
							strokes = [];
							break;
					}
				}
				
				_current_strokes = strokes;
			}
			return _current_strokes;
		};
	};
	
	/**
	 * The default Pen object.
	 */
	var Pen = function() {
	
		var _myoffset;
		
		var self = this;

		var _color = "#000000";
		var _opacity = 1.0;
		var _width = 1;
		
		// smoothing factor for fitting cubic Bezier curves to the lines
		// should be in range [0,1]
		// if set to 0 no smoothing occurs (control points collapse onto data points)
		var _smoothness = 0.5;
		
		// noise removal threshold for Douglas-Peucker algortihm:
		// points having squared Euclidean distance from the simplified line
		// smaller than this value will be removed
		var _dpThreshold = 3;

		// Drawing state
		var _drawing = false;
		var _c = null;
		var _points = [];

		self.color = function(value) {
			if (value === undefined){
		      	return _color;
		    }

			_color = value;

			return self;
		};

		self.width = function(value) {
			if (value === undefined) {
				return _width;
			} 

			if (value < Pen.MIN_WIDTH) {
				value = Pen.MIN_WIDTH;
			} else if (value > Pen.MAX_WIDTH) {
				value = Pen.MAX_WIDTH;
			}

			_width = value;

			return self;
		}

		self.opacity = function(value) {
			if (value === undefined) {
				return _opacity;
			} 

			if (value < 0) {
				value = 0;
			} else if (value > 1) {
				value = 1;
			}

			_opacity = value;

			return self;
		}

		self.start = function(e, sketchpad) {
			_drawing = true;

			/*var offset = $(sketchpad.canvas()).offset();*/
			var offset = $("#editor").offset();
			
			_points.push([e.pageX - offset.left, e.pageY - offset.top]);
			
			_c = sketchpad.paper().path();

			_c.attr({ 
				"stroke": _color,
				"stroke-opacity": _opacity,
				"stroke-width": 3,
				"stroke-linecap": "round",
				"stroke-linejoin": "round"
			});
		};

		self.move = function(e, sketchpad) {
			if (_drawing == true) {
				/*var offset = $(sketchpad.canvas()).offset();*/
				var offset = $("#editor").offset();
				/*console.log("pen.move(): offset: " + offset.left + "; " + offset.top);*/
				
				_points.push([e.pageX - offset.left, e.pageY - offset.top]);

				// calling point_to_svg() here rebuild the complete svg string each time from scratch
				// instead we could gradually construct is by appending the new points to its end...				
				_c.attr({ path: points_to_svg(false, 0, sketchpad) });
			}
		};
		
		self.finish = function(e, sketchpad) {
		
			//TODO: why are we getting this event twice??
			// => the event once comes from div.#editor
			// and once from Document
			//console.log(e);
			
			// return self.stop();
			var path = null;
						
			if (_c != null) {
				if (_points.length <= 1) {
					_c.remove();
				} else {
					
					_points = dp(_points, _dpThreshold);
					_c.attr( { path: points_to_svg(true, _smoothness) });
					
					/*
					for (var i = 0; i < _points.length; i++) {
						p = _points[i]; 
						var circle = sketchpad.paper().circle(p[0], p[1], 10);
						circle.attr("stroke", "#0000ff");
					}
					*/
					
					path = _c;
				}
			}
						
			_drawing = false;
			_c = null;
			_points = [];
					
			return path;
		};
		
		
		// ---------------------------------------------------------------------------
		// Douglas Peucker algorithm for poly-line simplification
		
		function dp(points, eps) {
		
			// handle points.length < 2
			if (points.length < 2) return points;
			
			var dmax = 0;
			var index = 0;
			
			// start- and endpoint of the line we want to simplify
			var start = points[0];
			var end   = points[points.length-1];

			// default distance function: measures distance between the line defined
			// by start and end and another point on the polyline
			var dist_fn = function(point) { return sqDistPointLine(point,start,end)};
			
			// special case: closed path, i.e. the start- and endpoint are equal
			// we need to use another distance function since start- and enpoint
			// fall together and thus do not form a line
			if (isEqual(start,end)) {
				dist_fn = function(point) {return sqDistPointPoint(point, start)};			
			}

			
			for (var i = 1; i < points.length-1; i++) {
				var dist = dist_fn(points[i]);
				if (dist > dmax) {
					index = i;
					dmax = dist;
				}
			}
			
			if (dmax > eps) {
				var r1 = dp(points.slice(0,index+1),eps);
				var r2 = dp(points.slice(index),eps);
				
				// concatenate the two results, avoiding duplicating the "center" point
				// in Matlab notation: result = [r1[1:end-1] r2[1:end]]
				var result = r1.slice(0,r1.length-1).concat(r2);
			} else {
				var result = [points[0], points[points.length-1]];
			}
			return result;
		}

		// squared Euclidean distance between two 2D points p1 and p2		
		function sqDistPointPoint(p1, p2) {
			var dx = p1[0] - p2[0];
			var dy = p1[1] - p2[1];
			return dx*dx + dy*dy;
		}
		
		// Orthogonal projection of p onto the line defined by l1, l2
		// Note: need to make sure that l1 != l2 when calling, otherwise
		// NaNs are returned
		function projectPointLine(p, l1, l2) {

			var denom = sqDistPointPoint(l1,l2);
			
			var nom = (p[0] - l1[0])*(l2[0] - l1[0]) + (p[1] - l1[1])*(l2[1] - l1[1]);
			var u = nom/denom;
			
			var x = l1[0] + u*(l2[0]-l1[0]);
			var y = l1[1] + u*(l2[1]-l1[1]);
			
			return [x,y];
		}
		
		// squared orthogonal distance between point p and the line defined by point l1, l2
		function sqDistPointLine(p, l1, l2) {
		
			projected = projectPointLine(p,l1,l2);
			return sqDistPointPoint(projected, p);
		}
		
		// end Douglas Peucker algorithm
		// ---------------------------------------------------------------------------
		
		// returns the Euclidean of a 2D vector
		function veclen(p) {
			return Math.sqrt(p[0]*p[0] + p[1]*p[1]);
		}

		// returns the 2D vector pointing from p0 to p1
		function vector(p0,p1) {
			return [p1[0]-p0[0], p1[1]-p0[1]];
		}
		
		// dot product between two 2D vectors
		function dot(a,b) {
			return a[0]*b[0] + a[1]*b[1];
		}
		
		function isEqual(p0,p1) {
			return p0[0] == p1[0] && p0[1] == p1[1];
		}
		
		// Given three 2D point p0,p1,p2 this computes control
		// points for a cubic bezier curve that smoothly approximates the polyline
		// defined by p0,p1,p2.
		// We make the control points lie on a line through p1 which is parallel to p0-p2
		// Let p be the projection of p1 onto the line defined by
		// p0 and p2. Then the control points' distances to p1 are proportinal
		// the to the distances of p from p0 and p from p2.
		// s is and additional smoothness scaling factor wich should be
		// in the range [0,1]. If set to zero, the control points collapse
		// onto p1.
		function computeControlPoints(p0,p1,p2,s) {
		
		
			// special case: p0 == p2
			// The triangle has an "infinitely small" angle
			// and the control points collapse onto p1
			if (isEqual(p0,p2)) return [p1,p1];
			
			
			// compute tangent direction from p0 to p2
			// and normalize to unit length
			var lx  = p2[0] - p0[0];
			var ly  = p2[1] - p0[1];
			var len = Math.sqrt(lx*lx + ly*ly);
			lx /= len;
			ly /= len;
			
			// project p1 onto line defined by p0 p2
			var p = projectPointLine(p1,p0,p2);
			var s0 = Math.sqrt(sqDistPointPoint(p0,p));
			var s2 = Math.sqrt(sqDistPointPoint(p2,p));
			

			// smoothing at a vertex is determined as a function of the
			// angle at that vertex
			var a = vector(p1,p0);
			var b = vector(p1,p2);
			var cosTheta = dot(a,b) / (veclen(a)*veclen(b));
			var sin = Math.sin(Math.acos(cosTheta)/2);
			sin*=sin;
			sin*=sin;
			
			var c0x = p1[0] - sin*s*s0*lx;
			var c0y = p1[1] - sin*s*s0*ly;
			
			var c2x = p1[0] + sin*s*s2*lx;
			var c2y = p1[1] + sin*s*s2*ly;
			
			return [[c0x,c0y], [c2x,c2y]];
		}
		
		
		// The idea is to approximate each line segment (define by two points p0,p1)
		// with a cubic bezier curve. This requires us to define two additional control
		// c1 and c2. For each line segment, we define c1 such that it is colinear with
		// c2 of the previous line segment, i.e. the Bezier curve achieves G1 continuity
		// along the line segments.
		// See http://www.w3.org/TR/SVG/paths.html#PathDataCubicBezierCommands for cubic
		// Bezier curves in SVG
		function points_to_svg(useBezier,s, sketchpad) {
								
			if (_points != null && _points.length > 1) {
			
				var p = _points[0];
				var path = "M" + p[0] + "," + p[1];
				var _cp;
		
				if (useBezier == true && _points.length > 2) {
					for (var i = 1; i < _points.length; i++) {
					
						// could make s dependent on the angle at p1
						// sine of that angle might be a good choice in order
						// to keep sharp edges
							
						var p0 = _points[i-1];
						var p1 = _points[i];
						
						// case1: first point of the line, make the first
						// control point identical with the first point
						if (i == 1) {
							var p2 = _points[i+1];
							var c = computeControlPoints(p0,p1,p2,s);
							var c0 = c[0];
							_cp = c[1]; // we need this control point in the next iteration so store it instead of recomputing it
							path += "C" + p0[0] + "," + p0[1] + " " + c0[0] + "," + c0[1] + " " + p1[0] + "," + p1[1];
						}
						
						// case2: last point of the path -> there is no next point, so
						// make the final control point identical with the last point
						else if (i == (_points.length-1)) {
							var c0 = _cp;
							path += "C" + c0[0] + "," + c0[1] + " " + p1[0] + "," + p1[1] + " " + p1[0] + "," + p1[1];
						} 
						
						// case3: arbitrary point on the line (without first and last one)
						else {
							var p2 = _points[i+1];
							var c = computeControlPoints(p0,p1,p2,s);
							var c0 = _cp;
							var c2 = c[0];
							path += "C" + c0[0] + "," + c0[1] + " " + c2[0] + "," + c2[1] + " " + p1[0] + "," + p1[1];							
							_cp = c[1];
						}
					}
					
				// in case we only have two points, or don't want to use the Bezier smoothing
				// just draw a simple polyline
				} else if (useBezier == false || _points.length == 2) {
					
					for (var i = 1; i < _points.length; i++) {
						var p = _points[i];
						path += "L" + p[0] + "," + p[1];
						//var circle = sketchpad.paper().circle(p[0], p[1], 5);
						//circle.attr("stroke", "#");

						
					}	
				}
							
				return path;
			} else {
				//console.log("discarding path; len: " + _points.length);
				return "";
			}
		};
	};
	
	Pen.MAX_WIDTH = 1000;
	Pen.MIN_WIDTH = 1;
	
	/**
	 * Utility to generate string representation of an object.
	 */
	function inspect(obj) {
		var str = "";
		for (var i in obj) {
			str += i + "=" + obj[i] + "\n";
		}
		return str;
	}
	
})(window.Raphael);

Raphael.fn.display = function(elements) {
	for (var i = 0, n = elements.length; i < n; i++) {
		var e = elements[i];
		var type = e.type;
		this[type]().attr(e);
	}
};


/**
 * Utility functions to compare objects by Phil Rathe.
 * http://philrathe.com/projects/equiv
 */

// Determine what is o.
function hoozit(o) {
    if (o.constructor === String) {
        return "string";
        
    } else if (o.constructor === Boolean) {
        return "boolean";

    } else if (o.constructor === Number) {

        if (isNaN(o)) {
            return "nan";
        } else {
            return "number";
        }

    } else if (typeof o === "undefined") {
        return "undefined";

    // consider: typeof null === object
    } else if (o === null) {
        return "null";

    // consider: typeof [] === object
    } else if (o instanceof Array) {
        return "array";
    
    // consider: typeof new Date() === object
    } else if (o instanceof Date) {
        return "date";

    // consider: /./ instanceof Object;
    //           /./ instanceof RegExp;
    //          typeof /./ === "function"; // => false in IE and Opera,
    //                                          true in FF and Safari
    } else if (o instanceof RegExp) {
        return "regexp";

    } else if (typeof o === "object") {
        return "object";

    } else if (o instanceof Function) {
        return "function";
    } else {
        return undefined;
    }
}

// Call the o related callback with the given arguments.
function bindCallbacks(o, callbacks, args) {
    var prop = hoozit(o);
    if (prop) {
        if (hoozit(callbacks[prop]) === "function") {
            return callbacks[prop].apply(callbacks, args);
        } else {
            return callbacks[prop]; // or undefined
        }
    }
}

// Test for equality any JavaScript type.
// Discussions and reference: http://philrathe.com/articles/equiv
// Test suites: http://philrathe.com/tests/equiv
// Author: Philippe RathÃƒÂ© <prathe@gmail.com>

var equiv = function () {

    var innerEquiv; // the real equiv function
    var callers = []; // stack to decide between skip/abort functions

    
    var callbacks = function () {

        // for string, boolean, number and null
        function useStrictEquality(b, a) {
            if (b instanceof a.constructor || a instanceof b.constructor) {
                // to catch short annotaion VS 'new' annotation of a declaration
                // e.g. var i = 1;
                //      var j = new Number(1);
                return a == b;
            } else {
                return a === b;
            }
        }

        return {
            "string": useStrictEquality,
            "boolean": useStrictEquality,
            "number": useStrictEquality,
            "null": useStrictEquality,
            "undefined": useStrictEquality,

            "nan": function (b) {
                return isNaN(b);
            },

            "date": function (b, a) {
                return hoozit(b) === "date" && a.valueOf() === b.valueOf();
            },

            "regexp": function (b, a) {
                return hoozit(b) === "regexp" &&
                    a.source === b.source && // the regex itself
                    a.global === b.global && // and its modifers (gmi) ...
                    a.ignoreCase === b.ignoreCase &&
                    a.multiline === b.multiline;
            },

            // - skip when the property is a method of an instance (OOP)
            // - abort otherwise,
            //   initial === would have catch identical references anyway
            "function": function () {
                var caller = callers[callers.length - 1];
                return caller !== Object &&
                        typeof caller !== "undefined";
            },

            "array": function (b, a) {
                var i;
                var len;

                // b could be an object literal here
                if ( ! (hoozit(b) === "array")) {
                    return false;
                }

                len = a.length;
                if (len !== b.length) { // safe and faster
                    return false;
                }
                for (i = 0; i < len; i++) {
                    if( ! innerEquiv(a[i], b[i])) {
                        return false;
                    }
                }
                return true;
            },

            "object": function (b, a) {
                var i;
                var eq = true; // unless we can proove it
                var aProperties = [], bProperties = []; // collection of strings

                // comparing constructors is more strict than using instanceof
                if ( a.constructor !== b.constructor) {
                    return false;
                }

                // stack constructor before traversing properties
                callers.push(a.constructor);

                for (i in a) { // be strict: don't ensures hasOwnProperty and go deep

                    aProperties.push(i); // collect a's properties

                    if ( ! innerEquiv(a[i], b[i])) {
                        eq = false;
                    }
                }

                callers.pop(); // unstack, we are done

                for (i in b) {
                    bProperties.push(i); // collect b's properties
                }

                // Ensures identical properties name
                return eq && innerEquiv(aProperties.sort(), bProperties.sort());
            }
        };
    }();

    innerEquiv = function () { // can take multiple arguments
        var args = Array.prototype.slice.apply(arguments);
        if (args.length < 2) {
            return true; // end transition
        }

        return (function (a, b) {
            if (a === b) {
                return true; // catch the most you can
            } else if (a === null || b === null || typeof a === "undefined" || typeof b === "undefined" || hoozit(a) !== hoozit(b)) {
                return false; // don't lose time with error prone cases
            } else {
                return bindCallbacks(a, callbacks, [b, a]);
            }

        // apply transition with (1..n) arguments
        })(args[0], args[1]) && arguments.callee.apply(this, args.splice(1, args.length -1));
    };

    return innerEquiv;

}();