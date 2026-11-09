with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Main is
   N : constant Integer := 8;
   type Int_Array is array (0 .. N - 1) of Integer;
   Data : Int_Array := (5, 3, 8, 1, 9, 2, 7, 4);

   type Bit_Type is mod 2**8;

   task type Swap_Task is
      entry Start (I, J, K : Integer);
      entry Finish;
   end Swap_Task;

   task body Swap_Task is
      Idx, Jmp, K_Param : Bit_Type;
      L : Bit_Type;
      Temp : Integer;
      Ascending : Boolean;
      Index_I, Index_L : Integer;
   begin
      accept Start (I, J, K : Integer) do
         Idx := Bit_Type(I);
         Jmp := Bit_Type(J);
         K_Param := Bit_Type(K);
      end Start;

      L := Idx xor Jmp;
      Index_I := Integer(Idx);
      Index_L := Integer(L);

      if L > Idx then
         Ascending := (Idx and K_Param) = 0;
         if (Ascending and (Data (Index_I) > Data (Index_L))) or
            (not Ascending and (Data (Index_I) < Data (Index_L)))
         then
            Temp := Data (Index_I);
            Data (Index_I) := Data (Index_L);
            Data (Index_L) := Temp;
         end if;
      end if;

      accept Finish;
   end Swap_Task;

   K : Integer := 2;
begin
   Put ("initial: ");
   for I in Data'Range loop
      Put (Data (I), Width => 0);
      Put (" ");
   end loop;
   New_Line;

   while K <= N loop
      declare
         J : Integer := K / 2;
      begin
         while J > 0 loop
            declare
               type Task_Array is array (0 .. N - 1) of Swap_Task;
               Tasks : Task_Array;
            begin
               for I in 0 .. N - 1 loop
                  Tasks (I).Start (I, J, K);
               end loop;
               for I in 0 .. N - 1 loop
                  Tasks (I).Finish;
               end loop;
            end;
            J := J / 2;
         end loop;
      end;
      K := K * 2;
   end loop;

   Put ("sorted: ");
   for I in Data'Range loop
      Put (Data (I), Width => 0);
      Put (" ");
   end loop;
   New_Line;
end Main;