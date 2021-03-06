require("common")
require("cothread")

LocalConnection = class();

function LocalConnection:ctor(host_peer,socket,handle)
    self.socket = socket;
    self.host_peer = host_peer;
    self.is_running = true;
    self.read_thread = nil;
    self.write_thread = nil;
    self.handle = handle;
    self.timeout = -1;
    self.start_time = 0;
    self.peer_name = nil;
end

function LocalConnection:StartForwarding()
    function _write_thread(thread);
        self:WriteThread(thread)
    end
    self.write_thread = CoThread.new();
    self.write_thread:Start(_write_thread);

    function _read_thread(thread);
        self:ReadThread(thread)
    end
    self.read_thread = CoThread.new();
    self.read_thread:Start(_read_thread);
end

function LocalConnection:WriteThread(thread)    
    local tmp = new_mem(64*1024);
    local send_qbuf = QueueFile.new(256*1024);

    self.start_time = App.GetSystemTimer();
    while self.socket:IsConnected() do
        tmp:SetSize(0);        
        if send_qbuf:GetFreeSize() >= tmp:GetMaxSize() then
            local rs = self.socket:Read(tmp,tmp:GetMaxSize());
            send_qbuf:Write(tmp,rs);
        end

        if send_qbuf:GetSize() > 0 then
            self.start_time = App.GetSystemTimer();
            local rs = send_qbuf:PeekData(tmp,tmp:GetMaxSize());
            assert(rs == tmp:GetSize(),"rs == tmp:GetSize()");
            self.host_peer:SetDestPeerName(self.peer_name);

            local success = false;

            for r=1,3,1 do
                local ret = self.host_peer:WriteData_Async(thread,self.handle,tmp);
                if not ret.value then 
                    printfnl("remote write fail: timeout.");
                    break;
                end

                local ws = ret.value.ws;
             
                if ws == -2 then
                    printfnl("remote write fail: %d, will retry %d.",ws,r);
                    thread:Sleep(1000);
                elseif ws < 0 then
                    printfnl("remote write fail: %d.",ws);
                    break;
                elseif ws > 0 then
                    send_qbuf:Skip(ws);
                    success = true;
                    break;
                end
            end

            if not success then
                break;
            end
        elseif self.timeout > 0 then
            local end_time = App.GetSystemTimer();
            if end_time - self.start_time > self.timeout then
                printf("local socket inactive timeout %d", self.handle);
                break;
            end
        end

        thread:Sleep(1);
    end

    self.socket:Destroy();
end

function LocalConnection:ReadThread(thread)    
    --no need
end

function LocalConnection:Write(data,size)
    if not self.socket:IsConnected() then
        return -1;
    end
    self.start_time = App.GetSystemTimer();
    return self.socket:Write(data,size);
end

function LocalConnection:IsConnected()
    return self.socket:IsConnected();
end

function LocalConnection:Close()
    if self.socket then
        self.socket:Destroy();
    end
end

function LocalConnection:SetTimeout(to)
    self.timeout = to;
end