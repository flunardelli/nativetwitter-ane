package com.palDeveloppers.ane
{
	public final class TweetCompositionResult
	{
		public static const OK:int = 0;
		public static const LONG_TEXT:int = 1;
		public static const BAD_IMAGE:int = 2;
		public static const LONG_URL:int = 4;
		public static const CANCELLED:int = 8;
		
		public function TweetCompositionResult()
		{
			throw new Error();
		}
	}
}