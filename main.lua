socket = require "socket"
copas = require "copas"
struct  = require "struct"
require "json"

local ServerIp = "*"
local ServerTcpPort = 1234

nb  = 0
cl  = 0     -- nb de
dt  = 0

Clients = {}

function log(str)
    print(str)
end

local tcpSocket = assert(socket.bind(ServerIp, ServerTcpPort))

function handler(skt)

    skt = copas.wrap(skt)

    local tcpIp, tcpPort = skt.socket:getpeername()

    Clients[tcpIp..":"..tcpPort] = {ip = tcpIp, port = tcpPort, skt = skt}
    print("new client:\t\t"..tcpIp..":"..tcpPort)
    local me = Clients[tcpIp..":"..tcpPort]

    cl = cl +1
    while true do
        nb=nb+1
        local data, status, partial = skt:receive()
        --print(data,status, partial)
        if data then
            print(data)
            x,y = struct.unpack("ii", data)
            print(x,y)
            --v.skt:send(data.."\n")
        end
        if status=="closed" then
            print(status..":\t\t\t"..tcpIp..":"..tcpPort)
            cl = cl - 1
            --for k,v in pairs(Admins) do
            --    v.skt:send("jso:"..json.encode(Clients[tcpIp..':'..tcpPort]).."\n")
            --end
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
