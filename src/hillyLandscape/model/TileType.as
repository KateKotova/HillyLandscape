/**
 * Пакет логических представлений игровых объектов.
 */
package hillyLandscape.model
{
	import enumerations.StringEnumeration;
	
	/**
	 * Класс типа плиточного замещения ландшафта.
	 */
	public final class TileType extends StringEnumeration
	{
		/**
		 * Неопределённый, не заданный.
		 */
		public static const UNDEFINED: TileType = new TileType( "UNDEFINED" );		
		/**
		 * Плитка земли.
		 */
		public static const GROUND: TileType = new TileType( "GROUND" );
		/**
		 * Последствия взрыва - обугленная воронка.
		 */
		public static const CRATER: TileType = new TileType( "CRATER" );
		/**
		 * Взрыв, огонёк.
		 */
		public static const EXPLOSION: TileType = new TileType( "EXPLOSION" );	
			
		/**
		 * Конструктор типа плиточного замещения ландшафта.
		 * @param parValue Значение текущего элемента.
		 */
		public function TileType( parValue: String )
		{
			this.Value = parValue;
		} // TileType			
	} // TileType
} // hillyLandscape.model