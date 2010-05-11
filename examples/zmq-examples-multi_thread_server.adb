with ZMQ.Sockets;
with ZMQ.Contexts;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
procedure ZMQ.examples.Multi_Thread_Server is

   task type server_task (ctx : not null access ZMQ.Contexts.Context;
                          id  : Integer) is
      entry start;
   end server_task;

   task body server_task is
      msg : Ada.Strings.Unbounded.Unbounded_String;
      s   : ZMQ.Sockets.Socket;
   begin
      accept start;
      s.Initialize (ctx.all, Sockets.REP);
      s.Connect ("inproc://workers");
      loop
         msg := s.recv;
         delay 1.0;
         Append (msg, "<Served by threa:" & id'Img & ">");
         s.Send (msg);
      end loop;
   end server_task;
   Number_Of_Servers : constant := 10;
   ctx              : aliased ZMQ.Contexts.Context;
   workers          : ZMQ.Sockets.Socket;
   clients          : ZMQ.Sockets.Socket;
   --  dev              : ZMQ.devices.device;
   servers          : array (1 .. Number_Of_Servers) of access server_task;
begin
   --  Initialise 0MQ context, requesting a single application thread
   --  and a single I/O thread
   ctx.Initialize (servers'Length + 1, 1, 0);

   --   Create a ZMQ_REP socket to receive requests and send replies
   workers.Initialize (ctx, Sockets.XREQ);
   workers.Bind ("inproc://workers");

   --   Bind to the TCP transport and port 5555 on the 'lo' interface
   clients.Initialize (ctx, Sockets.XREP);
   clients.Bind ("tcp://lo:5555");

   for i in servers'Range loop
      declare
         s : access server_task;
      begin
         s := new server_task (ctx'Access, i);
         s.start;
      end;
   end loop;
   --  dev.initialize (QUEUE, cliets, workers);

end ZMQ.Examples.Multi_Thread_Server;