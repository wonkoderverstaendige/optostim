function closeSerial(s)
    try
		fclose(s); 
	catch
	end
	delete(instrfind('Type', 'serial'));