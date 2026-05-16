function varargout = pigpen_gui(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pigpen_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @pigpen_gui_OutputFcn, ...
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

function pigpen_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;


cla(handles.axes_input);
axis(handles.axes_input, 'off');

cla(handles.axes_result);
axis(handles.axes_result, 'off');


handles.pigpenFolder = 'pigpen_symbols';
if ~exist(handles.pigpenFolder, 'dir')
    mkdir(handles.pigpenFolder);
    warndlg('Folder "pigpen_symbols" dibuat. Silakan tambahkan gambar A.png sampai Z.png', 'Peringatan');
end

guidata(hObject, handles);

function varargout = pigpen_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function edit_input_Callback(hObject, eventdata, handles)
textInput = upper(get(hObject, 'String'));


function edit_input_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_key_Callback(hObject, eventdata, handles)
keyStr = get(hObject, 'String');
keyStr = strrep(keyStr, ',', '.'); 

if ~isempty(keyStr)
    key = str2double(keyStr);
    if isnan(key) || ~isreal(key) || mod(key, 1) ~= 0
         errordlg('Kunci harus berupa bilangan bulat!', 'Error');
    else
        
        set(hObject, 'String', num2str(key));
    end
end
function edit_key_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_key_KeyPressFcn(hObject, eventdata, handles)

currentText = get(hObject,'String');
allowedKeys = {'0','1','2','3','4','5','6','7','8','9','-',...
              'backspace','delete','leftarrow','rightarrow'};


if any(eventdata.Character == ',.') && contains(currentText, ['.', ','])
    set(hObject, 'UserData', 'ignore');
    return;
end

if ~any(strcmp(eventdata.Key, allowedKeys)) && ...
   ~isempty(eventdata.Character) && ...
   ~any(strcmp(eventdata.Character, {'.',','}))
    set(hObject, 'UserData', 'ignore');
else
    set(hObject, 'UserData', 'allow');
end

function push_encrypt_Callback(hObject, eventdata, handles)
textInput = upper(get(handles.edit_input, 'String'));
keyStr = get(handles.edit_key, 'String');
keyStr = strrep(keyStr, ',', '.');
key = str2double(keyStr);

if isnan(key) || ~isreal(key) || mod(key, 1) ~= 0
    errordlg('Kunci harus berupa bilangan bulat!', 'Error');
    return;
end

cipher = caesar_cipher(textInput, key, 'encrypt');
set(handles.text_result, 'String', cipher);

cla(handles.axes_input);
display_pigpen(cipher, handles.axes_result, handles.pigpenFolder);

function push_decrypt_Callback(hObject, eventdata, handles)
textInput = upper(get(handles.edit_input, 'String'));
keyStr = get(handles.edit_key, 'String');
keyStr = strrep(keyStr, ',', '.');
key = str2double(keyStr);

if isnan(key) || ~isreal(key) || mod(key, 1) ~= 0
    errordlg('Kunci harus berupa bilangan bulat!', 'Error');
    return;
end

plain = caesar_cipher(textInput, key, 'decrypt');
set(handles.text_result, 'String', plain);

cla(handles.axes_result);
display_pigpen(textInput, handles.axes_input, handles.pigpenFolder);

function text_result_CreateFcn(hObject, eventdata, handles)

function axes_input_CreateFcn(hObject, eventdata, handles)
axis off;

function axes_result_CreateFcn(hObject, eventdata, handles)
axis off;

function out = caesar_cipher(text, key, mode)
out = '';
for i = 1:length(text)
    ch = upper(text(i));
    if isletter(ch)
        base = double('A');
        idx = double(ch) - base;
        if strcmp(mode, 'encrypt')
            idx = mod(idx + key, 26);
        else
            idx = mod(idx - key + 26, 26);
        end
        out(end+1) = char(base + idx);
    elseif ch == ' '
        out(end+1) = ' ';
    end
end

function display_pigpen(text, axesHandle, folder)
cla(axesHandle);
axis(axesHandle, 'off');

if isempty(text)
    text(0.5, 0.5, 'Tidak ada teks untuk ditampilkan', ...
        'HorizontalAlignment', 'center', 'Parent', axesHandle);
    return;
end

if ~exist(folder, 'dir')
    text(0.5, 0.5, 'Folder simbol tidak ditemukan', ...
        'HorizontalAlignment', 'center', 'Parent', axesHandle);
    return;
end

pigpenImages = {};
missingChars = [];

for i = 1:length(text)
    ch = upper(text(i));
    if ch >= 'A' && ch <= 'Z'
        imgPath = fullfile(folder, [ch '.png']);
        if exist(imgPath, 'file')
            pigpenImages{end+1} = imread(imgPath);
        else
            img = 255 * ones(200, 200, 3, 'uint8');
            pigpenImages{end+1} = insertText(img, [60 80], ch, 'FontSize', 100, 'BoxColor', 'white', 'TextColor', 'black');
            missingChars = [missingChars ch];
        end
    elseif ch == ' '
        pigpenImages{end+1} = 255 * ones(200, 60, 3, 'uint8'); 
    end
end

if ~isempty(missingChars)
    warndlg(['Simbol untuk huruf berikut tidak ditemukan: ' unique(missingChars)], 'Peringatan');
end

if ~isempty(pigpenImages)
    
    imgSize = size(pigpenImages{1});
    for i = 2:length(pigpenImages)
        pigpenImages{i} = imresize(pigpenImages{i}, [imgSize(1) imgSize(2)]);
    end
    
   
    result = pigpenImages{1};
    for i = 2:length(pigpenImages)
        result = [result pigpenImages{i}];
    end
    
    axes(axesHandle);
    imshow(result);
    axis(axesHandle, 'off');
else
    text(0.5, 0.5, 'Tidak ada teks untuk ditampilkan', ...
        'HorizontalAlignment', 'center', 'Parent', axesHandle);
end

function push_clear_Callback(hObject, eventdata, handles)

set(handles.edit_input, 'String', '');
set(handles.edit_key, 'String', '');
set(handles.text_result, 'String', '');


cla(handles.axes_input);
axis(handles.axes_input, 'off');

cla(handles.axes_result);
axis(handles.axes_result, 'off');

function push_clear_CreateFcn(hObject, eventdata, handles)

function push_close_Callback(hObject, eventdata, handles)

selection = questdlg('Apakah Anda yakin ingin menutup aplikasi?',...
                    'Konfirmasi Penutupan',...
                   'Ya','Tidak','Tidak');
                

switch selection
    case 'Ya'
       
        delete(handles.figure1);
    case 'Tidak'
       
        return;
end

function push_close_CreateFcn(hObject, eventdata, handles)
