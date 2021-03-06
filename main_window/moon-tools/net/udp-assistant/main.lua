require("common");
require("user");
require("bson");
require("win32");

local UI_WND_HEIGHT=150;

App.ClearScreen();
App.StartNet();

App.ShowEmbeddedUIWindow(UI_WND_HEIGHT);
local hwnd = App.GetHWnd(HWND_EMBEDDED_UI);

if not hwnd then
    printnl("can not find embedded ui window");
    return
end

local _,_,UI_WND_WIDTH = Win32.GetClientRect(hwnd);

local udp_socket = UdpSocket.new();
udp_socket:Create();

if not udp_socket:Bind(local_port) then
    printfnl("bind fail on port %d",local_port);
    return
end

udp_socket:SetDestIpAndPort(remote_ip,remote_port);

local editbox = EditBox.new();
editbox:SetParent(hwnd);

editbox:AddStyle(
    ES_MULTILINE|ES_NOHIDESEL |
    WS_VSCROLL|ES_AUTOVSCROLL |
    ES_AUTOHSCROLL|ES_WANTRETURN |
    WS_BORDER
);

editbox:Create();
editbox:SetStockFont(SYSTEM_FIXED_FONT);

local button = Button.new();
button:SetParent(hwnd);
button:Create();
button:SetStockFont(SYSTEM_FIXED_FONT);
button:SetText("发送");

function relayout(width,height)
    local btn_width ,btn_height = 80, height-40;
    editbox:MoveWindow(
        10,10,
        width-btn_width-50,height-20
    );    
    
    button:MoveWindow(
        width - btn_width - 20, 
        (height-btn_height)/2,
        btn_width,btn_height
    );
end

function on_send_click()
    local len = editbox:GetTextLen();
    
    if len <= 0 then
        return
    end
    
    local mem = new_mem(len*4);
    editbox:GetText(mem);
    if clear_after_send then
        editbox:SetText("");
    end
    
    send_user_message(mem);
    mem:Destroy();
end

App.SetOnAppEvent(function(e,data)

    local msg;
    
    if e == APP_EVENT_EMBEDDED_UI_WINDOW_RESIZED or 
       e == APP_EVENT_EMBEDDED_UI_WINDOW_MESSAGE 
    then
		local bson = Bson.new();
		bson:LoadBson(data);
		msg = BsonToObject(bson);		
    end

	if e == APP_EVENT_EMBEDDED_UI_WINDOW_RESIZED then			
        relayout(msg.right,msg.bottom);
	end
    
    if e == APP_EVENT_EMBEDDED_UI_WINDOW_MESSAGE then
        
        if msg.message == WM_COMMAND then
            if button:IsMyCommand(msg.wparam) then
                on_send_click();
            end
        end    
    end    
end);

function receive_thread(thread)
    local mem = new_mem(256*1024);
    
    while true do        
        if udp_socket:RecvMsg(mem) then
            received_message(mem);            
        end
        thread:Sleep(1);
    end
end

function send_message(mem)
    udp_socket:SendMsg(mem);
end

function send_user_message(mem)
    if use_hex then
        local bin_file = new_mem(mem:GetSize());
        hex_file_to_bin_file(mem,bin_file);
        mem:Destroy();
        mem = bin_file;
    end
    send_message(mem);
end

local cur_pos = 0;
function print_hex(mem)
    mem:Seek(0);
    for i=1,mem:GetSize(),1 do
        local ch = mem:Getc();
        printf("%02x ",(ch&0xff));
        cur_pos = cur_pos + 1;
        if cur_pos >= 20 then
            printnl("");
            cur_pos = 0;
        end
    end
end

function received_message(mem)
    after_recv_msg(mem);
    if not use_hex then
        print_whole_file(mem);
    else
        print_hex(mem);
    end
end

local co = CoThread.new();
co:Start(receive_thread,co);

local user_co = CoThread.new();
user_co:Start(user_thread,user_co);

relayout(UI_WND_WIDTH,UI_WND_HEIGHT);

App.MainLoop();

