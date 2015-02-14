socket = require "socket"
copas = require "copas"
struct  = require "struct"
require "json"

local ServerIp = "*"
local ServerTcpPort = 54321

nb  = 0
cl  = 0     -- nb de
dt  = 0

Clients = {}

players = {
    {x = 0, y = 0},
    {x = 0, y = 0},
    {x = 0, y = 0},
    {x = 0, y = 0},
    {x = 0, y = 0}
}

function log(str)
    print(str)
end

local tcpSocket = assert(socket.bind(ServerIp, ServerTcpPort))

function handler(skt)

    skt = copas.wrap(skt)

    local tcpIp, tcpPort = skt.socket:getpeername()

    Clients[tcpIp..":"..tcpPort] = {ip = tcpIp, port = tcpPort, skt = skt, x = 0, y = 0}
    print("new client:\t\t"..tcpIp..":"..tcpPort)
    local me = Clients[tcpIp..":"..tcpPort]

    cl = cl +1
    for k,v in ipairs(Clients) do
        msg = struct.pack("dd", v.x, v.y);
        me.skt:send(msg)
    end
    while true do
        nb=nb+1
        local data, status, partial = skt:receive(17)
        --print(data,status, partial)
        if data then
        --    print(data)
            x,y = struct.unpack("dd", data)
            print(x,y)
            me.x = x
            me.y = y

            for k,v in ipairs(Clients) do
                msg = struct.pack("dd", v.x, v.y);
                me.skt:send(msg)
            end
        end
        if status=="closed" then
            print(status..":\t\t\t"..tcpIp..":"..tcpPort)
            cl = cl - 1
            Clients[tcpIp..':'..tcpPort] = nil
            break
        end
    end
end

copas.addserver(tcpSocket, handler)


while 42 do
    copas.step(0)
    socket.sleep(0.2)
end
