package com.components
{
	public class DateConv
	{
		public function DateConv()
		{
		}
		public static function convert(dateNumber:String):String{
			var s:String			
			switch(dateNumber){
				case "01":
				s = "JAN"
				break;
				case "02":
				s = "FEB"
				break;
				case"03":
				s = "MAR"
				break;
				case "04":
				s = "APR"
				break;
				case"05":
				s = "MAY"
				break;
				case"06":
				s = "JUN"
				break;
				case"07":
				s = "JUL"
				break;
				case"08":
				s = "AUG"
				break;
				case"09":
				s = "SEPT"
				break;
				case "10":
				s = "OCT"
				break;
				case "11":
				s = "NOV"
				break;
				case"12":
				s="DEC"
				break;
				
				case "1":
					s = "JAN"
					break;
				case "2":
					s = "FEB"
					break;
				case"3":
					s = "MAR"
					break;
				case "4":
					s = "APR"
					break;
				case"5":
					s = "MAY"
					break;
				case"6":
					s = "JUN"
					break;
				case"7":
					s = "JUL"
					break;
				case"8":
					s = "AUG"
					break;
				case"9":
					s = "SEPT"
					break;
				case"default":
					s = "Null"
					break;
			}
			
			return s
		}
	}
}