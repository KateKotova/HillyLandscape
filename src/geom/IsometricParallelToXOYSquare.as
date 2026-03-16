/**
 * Пакет классов геометрии.
 */
package geom
{
	import flash.geom.Point;

	/**
	 * Ромб - изометрическая проекция квадрата, лежащего в плоскости,
	 * параллельной кординатной плоскости XOY -
	 * изометрический прямоугольник с равными сторонами.
	 */
	public class IsometricParallelToXOYSquare
		extends IsometricParallelToXOYRectangle
	{
		/**
		 * Конструктор изометрического квадрата.
		 * @param parTopAndLocalOrigin Координаты верхнего угла
		 * в объекте-контейнере - локальное начало координат.
		 * @param parSide Сторона по оси OX, равная стороне по оси OY.
		 */
		public function IsometricParallelToXOYSquare( parTopAndLocalOrigin: Point,
			parSide: Number )
		{	
			super( parTopAndLocalOrigin, parSide, parSide );
			/**this._TopAndLocalOrigin = parTopAndLocalOrigin;
			this.SetSide( parSide );*/
		} // IsometricParallelToXOYSquare		
		
		/**
		 * Изменение размеров изметрического квадрата. Его стороны по осям кооринат
		 * равны. Это сохраняется и при проецировании на объект контейнер,
		 * поскольку проекцией квадрата является ромб.
		 * Вершина, то есть верхняя точка, остаётся на месте, это локальное
		 * начало координат. Задаётся величина сторон, принадлежащих локальным осям:
		 * оси оридант, идущей врпво-вниз, и оси абсции, идущей влево-вниз.
		 * По этой величине перечитываются координаты остальных 3 точек.
		 * @param parSide Сторона по оси OX, равная стороне по оси OY.
		 */
		public function SetSide( parSide: Number ): void
		{
			parSide = Math.max( parSide, IsometricXOYGrid.MINIMUM_CELL_SIDE );
			
			// На сцене координаты ориентированы по другому:
			// по вертикали сверху вниз направлена ось ординат,
			// по горизонтали слева направо - ось абсцисс.
			
			// Возьмём отрезок между правой и левой точкой.
			// Чтобы найти новые кооринаты правой точки,
			// проведём из верхней точки прямую, прараллельную оси оринат сцены,
			// проведём из правой точки прямую, прараллельную оси абсцисс сцены.
			// На их пересечении получится ещё она точка, которая вместе
			// с верхней и правой образует прямоугольный треугольник.
			// Его катеты - это величины смещений координат правой точки
			// относительно верхней.
			// Вертикальный катет противолежит углу в 30 градусов,
			// поэтому равен половине гипотенузы.
			// Горизонтальный катет противолежит углу в 60 градусов,
			// его можно найти как sin( 60 ) = ( sqrt( 3 ) / 2 ),
			// умноженный на гипотенузу.
			
			// Смещение правой точки, оно же - смещение левой точки.
			var offset: Point = new Point( parSide * Utils.SIN_60, parSide / 2 );												 
			
			this._Right.x = this._TopAndLocalOrigin.x + offset.x;
			this._Right.y = this._TopAndLocalOrigin.y + offset.y;
			
			this._Left.x = this._TopAndLocalOrigin.x - offset.x;
			this._Left.y = this._TopAndLocalOrigin.y + offset.y;
			
			this._Bottom.x = this._TopAndLocalOrigin.x;
			this._Bottom.y = this._TopAndLocalOrigin.y + 2 * offset.y;
		} // SetSide		

		/**
		 * Изменение размеров изметрического квадрата. Вершина, то есть
		 * верхняя точка, остаётся на месте, это локальное начало координат.
		 * Задаются величины сторон, принадлежащие локальным осям:
		 * оси оридант, идущей врпво-вниз, и оси абсции, идущей влево-вниз.
		 * По этим величинам перечитываются координаты остальных 3 точек.
		 * У квадрата и его проекции - ромба - все стороны равны.
		 * @param parXSide Сторона по оси OX.
		 * @param parYSide Сторона по оси OY.
		 */		 
		public override function SetSize( parXSide: Number, parYSide: Number ): void
		{
			this.SetSide( Math.min( parXSide, parYSide ) );
		} // SetSize
		
		/**
		 * Перемещение всего изометрического квадрата на заданные велечины
		 * смещений по осям OX и OY (координаты объекта-контейнера),
		 * представленные в виде координат точки.
		 * @param parOffset Смещения по осям OX и OY.
		 * @return Перемещённый изометрический прямоугольник.		 
		 */
		public override function GetMoved( parOffset: Point )
			: IsometricParallelToXOYRectangle
		{
			return new IsometricParallelToXOYSquare
				( new Point( this._TopAndLocalOrigin.x + parOffset.x,
				this._TopAndLocalOrigin.y + parOffset.y ), this.Side );
		} // GetMoved		
		
		/**
		 * Длина стороны (у квадрата и его проекции - ромба - все стороны равны).
		 * @return Длина стороны.
		 */		
		public function get Side( ): Number
    { 
			// Катет, лежащий против угла в 30 градусов равен половине гипотенузы.
      return 2 * ( this._Right.y - this._TopAndLocalOrigin.y );
		}	// get Side			
	}	// IsometricParallelToXOYSquare
} // geom
