with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Main is
   Upper : constant Integer := 100_000;
   Num_Tasks : constant Integer := 4;
   Chunk : constant Integer := (Upper - 1) / Num_Tasks;

   protected Counter is
      procedure Increment;
      function Value return Integer;
   private
      Count : Integer := 0;
   end Counter;

   protected body Counter is
      procedure Increment is
      begin
         Count := Count + 1;
      end Increment;

      function Value return Integer is
      begin
         return Count;
      end Value;
   end Counter;

   task type Prime_Worker is
      entry Start (Low, High : Integer);
      entry Finish;
   end Prime_Worker;

   task body Prime_Worker is
      L, H : Integer;
      Is_Prime : Boolean;
   begin
      accept Start (Low, High : Integer) do
         L := Low;
         H := High;
      end Start;

      for N in L .. H loop
         if N < 2 then
            Is_Prime := False;
         else
            Is_Prime := True;
            declare
               D : Integer := 2;
            begin
               while D * D <= N loop
                  if N mod D = 0 then
                     Is_Prime := False;
                     exit;
                  end if;
                  D := D + 1;
               end loop;
            end;
         end if;

         if Is_Prime then
            Counter.Increment;
         end if;
      end loop;

      accept Finish;
   end Prime_Worker;

   type Worker_Array is array (1 .. Num_Tasks) of Prime_Worker;
   Workers : Worker_Array;
begin
   for K in Worker_Array'Range loop
      declare
         Lo : constant Integer := 2 + (K - 1) * Chunk;
         Hi : constant Integer :=
           (if K = Num_Tasks then Upper else Lo + Chunk - 1);
      begin
         Workers (K).Start (Lo, Hi);
      end;
   end loop;

   for K in Worker_Array'Range loop
      Workers (K).Finish;
   end loop;

   Put ("primes up to ");
   Put (Upper, Width => 0);
   Put (": ");
   Put (Counter.Value, Width => 0);
   New_Line;
end Main;