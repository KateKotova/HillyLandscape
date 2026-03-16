/**
 * Пакет классов геометрии.
 */
package geom
{
	import flash.geom.Point;

	/**
	 * Класс геометрических полезностей.
	 */
	public final class Utils
	{
		/**
		 * Синус 60 градусов: sin( 60 ) = sqrt( 3 ) / 2.
		 */
		public static const SIN_60: Number = Math.sqrt( 3 ) / 2;
		
		/**
		 * Подсчёт значения линейной функции от заданного аргумента
		 * с использованием уравнения прямой, проходящей через две заданные точки:
		 * y = ( y2 - y1 ) * ( x - x1 ) / ( x2 - x1 ) + y1, где
		 * ( x1; y1 ) и ( x2; y2 ) - координаты двух известных точек.
		 * @param parPoint1 Координаты первой точки.
		 * @param parPoint2 Координаты второй точки.
		 * @param parX Аргумент функции.
		 * @return Значение линейной функции в заданной точке.
		 */
		public static function LinearFunctionValue( parPoint1: Point,
			parPoint2: Point, parX: Number ): Number
		{
			return ( parPoint2.y - parPoint1.y ) * ( parX - parPoint1.x )
				/ ( parPoint2.x - parPoint1.x ) + parPoint1.y;
		} // LinearFunctionValue
	}	// Utils
} // geom
