package data_types is
	constant g_IMAGE_ROWS : natural := 8;
	constant g_IMAGE_COLS : natural := 4;
	constant g_Bits : natural := 32;
	type a_t is array(natural range <>) of integer;
	type myMatrix is array(natural range <>, natural range <>) of integer;

	type myVector is array(natural range <>) of a_t(0 to g_IMAGE_COLS-1);
end package data_types;