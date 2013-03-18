function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 24-Nov-2011 12:13:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% -------------------------------------------------------------------------

handles.shapebm_params_motorbikes          = varargin{1};
handles.shapebm_params_horses              = varargin{2};
handles.dataset_motorbikes                 = varargin{3};
handles.dataset_horses                     = varargin{4};

handles.active_params                      = handles.shapebm_params_horses;
handles.active_dataset                     = handles.dataset_horses;
handles.settings                           = gui_settings_horses();

% -------------------------------------------------------------------------

% initialize
gui_init(hObject, handles);

% begin the draw loop
gui_draw(guidata(hObject));

% Set up callbacks
set(gcf, 'WindowButtonDownFcn', @(hObject, eventdata) mouse_down_fcn(hObject, eventdata));
set(gcf, 'WindowButtonUpFcn', @(hObject, eventdata) mouse_up_fcn(hObject, eventdata));
set(gcf, 'WindowButtonMotionFcn', @(hObject, eventdata) mouse_motion_fcn(hObject, eventdata));
set(gcf, 'KeyPressFcn', @(hObject, eventdata) key_press_fcn(hObject, eventdata));


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
selection = contents{get(hObject,'Value')};
guidata(hObject, handles);

if contains(selection, 'Motorbikes')
    handles.active_params = handles.shapebm_params_motorbikes;
    handles.active_dataset = handles.dataset_motorbikes;
    handles.settings = gui_settings_motorbikes();
    
else
    handles.active_params = handles.shapebm_params_horses;
    handles.active_dataset = handles.dataset_horses;
    handles.settings = gui_settings_horses();
end

gui_init(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.pushbutton1, 'Enable', 'off');
set(handles.pushbutton2, 'Enable', 'on');
set(handles.pushbutton3, 'Enable', 'off');
set(handles.pushbutton4, 'Enable', 'off');
gui_chain(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.pushbutton1, 'Enable', 'on');
set(handles.pushbutton2, 'Enable', 'off');
set(handles.pushbutton3, 'Enable', 'on');
set(handles.pushbutton4, 'Enable', 'on');


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_init(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_init(hObject, handles, true);

% --- Mouse down callback.
function mouse_down_fcn(hObject, eventdata)

handles = guidata(hObject);
handles.is_painting = true;
guidata(hObject, handles);
gui_motion(hObject, guidata(hObject));


% --- Mouse up callback.
function mouse_up_fcn(hObject, eventdata)

handles = guidata(hObject);
handles.is_painting = false;
guidata(hObject, handles);


% --- Mouse motion callback.
function mouse_motion_fcn(hObject, eventdata)

handles = guidata(hObject);
gui_motion(hObject, handles);


% --- Key press callback.
function key_press_fcn(hObject, eventdata)

handles = guidata(hObject);

if eventdata.Key == 's' || eventdata.Key == 'S'
    
    if equals(get(handles.pushbutton1, 'Enable'), 'on')
        pushbutton1_Callback(hObject, eventdata, handles);
    else
        pushbutton2_Callback(hObject, eventdata, handles);
    end
    
elseif eventdata.Key == 'c' || eventdata.Key == 'C'
        
    togglebutton1_Callback(hObject, eventdata, handles);
        
elseif eventdata.Key == 'u' || eventdata.Key == 'U'
        
    togglebutton2_Callback(hObject, eventdata, handles);
        
elseif eventdata.Key == 'w' || eventdata.Key == 'W'
        
    togglebutton3_Callback(hObject, eventdata, handles);
        
elseif eventdata.Key == 'b' || eventdata.Key == 'B'
        
    togglebutton4_Callback(hObject, eventdata, handles);
    
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.togglebutton1, 'Value') == 0
    set(handles.togglebutton1, 'Value', 1);
end

set(handles.togglebutton2, 'Value', 0);
set(handles.togglebutton3, 'Value', 0);
set(handles.togglebutton4, 'Value', 0);

set(handles.pushbutton1, 'Enable', 'on');
set(handles.pushbutton2, 'Enable', 'off');

handles.brush_type = 'cut';
guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.togglebutton2, 'Value') == 0
    set(handles.togglebutton2, 'Value', 1);
end

set(handles.togglebutton1, 'Value', 0);
set(handles.togglebutton3, 'Value', 0);
set(handles.togglebutton4, 'Value', 0);

set(handles.pushbutton1, 'Enable', 'on');
set(handles.pushbutton2, 'Enable', 'off');

handles.brush_type = 'uncut';
guidata(hObject, handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.togglebutton3, 'Value') == 0
    set(handles.togglebutton3, 'Value', 1);
end

set(handles.togglebutton1, 'Value', 0);
set(handles.togglebutton2, 'Value', 0);
set(handles.togglebutton4, 'Value', 0);

set(handles.pushbutton1, 'Enable', 'on');
set(handles.pushbutton2, 'Enable', 'off');

handles.brush_type = 'white';
guidata(hObject, handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over togglebutton4.
function togglebutton4_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.togglebutton4, 'Value') == 0
    set(handles.togglebutton4, 'Value', 1);
end

set(handles.togglebutton1, 'Value', 0);
set(handles.togglebutton2, 'Value', 0);
set(handles.togglebutton3, 'Value', 0);

set(handles.pushbutton1, 'Enable', 'on');
set(handles.pushbutton2, 'Enable', 'off');

handles.brush_type = 'black';
guidata(hObject, handles);
