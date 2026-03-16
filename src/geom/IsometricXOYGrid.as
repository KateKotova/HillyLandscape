/**
 * Пакет классов геометрии.
 */
package geom
{
	import flash.geom.Point;

	/**
	 * Изометрическая сетка.
	 * В стандартной ортогональной изометрической проекции начало координат -
	 * в центре. Аксонометрические оси образуют между собой углы в 120 градусов.
	 * Ось аппликат направлена снизу вверх, поэтому все вертикально направленные
	 * линии параллельны ей.
	 * Ось абсцисс от начала координат направлена влево-вниз, поэтому линии,
	 * параллельные ей имеют направление слева-снизу вправо-вверх и наоборот.
	 * Ось ординат от начала координат направлена врпво-вниз, поэтому линии,
	 * параллельные ей имеют направление справа-снизу влево-вверх и наоборот.
	 * Данная сетка представляет собой разделение плоскости XOY
	 * на одинаковые изометрические квадраты, проекции которых
	 * на объект контейнер представляют собой ромбы.
	 */
	public class IsometricXOYGrid
	{
		/**
		 * Минимальная сторона изометрического квадрата-клетки в пикселях.
		 */
		public static const MINIMUM_CELL_SIDE: Number = 1;
		/**
		 * Сообщение о некорректном значении стороны клетки в пикселях.
		 */
		public static const INCORRECT_CELL_SIDE_MESSAGE: String = "Некорректное "
			+ "значение стороны клетки изометрической сетки в пикселях: ";
		/**
		 * Сообщение о коррекции стороны клетки.
		 */
		public static const CELL_SIDE_WAS_CORRECTED_MESSAGE: String = "Сторона "
			+ "клетки изометрической сетки в пикселях была откорректирована: ";
		/**
		 * Сообщение об изменении стороны клетки.
		 */
		public static const CELL_SIDE_CHANGING_MESSAGE: String = " заменено на ";
		
		/**
		 * Сторона клетки изметрической сетки в пикселях.
		 */
		private var _CellSide: Number = IsometricXOYGrid.MINIMUM_CELL_SIDE;
		
		/**
		 * Половина высоты проекции клетки на плоскость сцены.
		 * При изометрическом проецировании клетка на сцене выглядит как ромб.
		 * Угол между осями абсцисс и ординат - 120 градусов.
		 * Соединив центр ромба с вершинами клетки, получаются 4 равных,
		 * взаимно зеркально отображаемых прямоугольных треугольника.
		 * Для такого треугоьлника длина сетки - гипотенуза, а два угла равны:
		 * 120 / 2 = 60 и 180 - 90 - 60 = 30.
		 * Катет, противолежащий углу в 30 градусов равен половине гипотенузы,
		 * то есть половина высоты проекции клетки на плоскость сцены -
		 * сторона сетки пополам.
		 */
		private var _CellProjectionHeightHalf: Number
			= IsometricXOYGrid.MINIMUM_CELL_SIDE / 2;
		/**
		 * Половина ширины проекции клетки на плоскость сцены.
		 * При изометрическом проецировании клетка на сцене выглядит как ромб.
		 * Угол между осями абсцисс и ординат - 120 градусов.
		 * Соединив центр ромба с вершинами клетки, получаются 4 равных,
		 * взаимно зеркально отображаемых прямоугольных треугольника.
		 * Для такого треугоьлника длина сетки - гипотенуза, а два угла равны:
		 * 120 / 2 = 60 и 180 - 90 - 60 = 30.
		 * Половина ширины проекции клетки на плоскость сцены -
		 * катет, противолежащий углу в 60 грудусов. Sin( 60 ) = sqst( 3 ) / 2.
		 * Тогда половина ширины проекции клетки на плоскость сцены:
		 * сторона сетки, умноженная на sqst( 3 ) / 2.
		 */
		private var _CellProjectionWidthHalf: Number
			= IsometricXOYGrid.MINIMUM_CELL_SIDE * Utils.SIN_60;			
		
		/**
		 * Конструктор изометрической сетки.
		 * @param parCellSide Сторона клетки-изометрического квадрата.
		 */
		public function IsometricXOYGrid( parCellSide: Number
			= IsometricXOYGrid.MINIMUM_CELL_SIDE )
		{
			this.InitializeCellSide( parCellSide );
			// Половина высоты проекции клетки на плоскость сцены.
			// Сторона клетки на синус 30 градусов.
			this._CellProjectionHeightHalf = this._CellSide / 2;
			// Половина ширины проекции клетки на плоскость сцены.
			// Сторона клетки на синус 60 градусов.
			this._CellProjectionWidthHalf = this._CellSide * Utils.SIN_60;			
		} // IsometricXOYGrid
		
		/**
		 * Метод инициализации стороны клетки изометрической сетки в пикселях.
		 * @param parCellSide Сторона клетки изометрической сетки в пикселях. 
		 */
		private function InitializeCellSide( parCellSide: Number ): void
		{
			// Сообщение о том, что сторона клетки была изменена.
			const CELL_SIDE_WAS_CHANGED_MESSAGE: String
				= IsometricXOYGrid.CELL_SIDE_WAS_CORRECTED_MESSAGE + parCellSide
				+ IsometricXOYGrid.CELL_SIDE_CHANGING_MESSAGE;
				
			if ( isNaN( parCellSide ) || ( parCellSide == Infinity )
				|| ( parCellSide == -Infinity ) )
			{
				trace( IsometricXOYGrid.INCORRECT_CELL_SIDE_MESSAGE + parCellSide );
				parCellSide = IsometricXOYGrid.MINIMUM_CELL_SIDE;
				trace( CELL_SIDE_WAS_CHANGED_MESSAGE + parCellSide );
			} // if
			else			
				// Сторона клетки должна быть положительным числом.
				if ( parCellSide < 1 )
				{
						parCellSide = IsometricXOYGrid.MINIMUM_CELL_SIDE;
						trace( CELL_SIDE_WAS_CHANGED_MESSAGE + parCellSide );
				} // if
			
			this._CellSide = parCellSide;
		} // InitializeCellSide
		
		/**
		 * Возврат вершины клетки с заданными индексами.
		 * @param parX Индекс по оси абсцисс раположения клетки от нуля.
		 * @param parY Индекс по оси ординат раположения клетки от нуля.
		 * @return Вершина клетки, заданной индексами клетки по осям OX и OY.
		 */
		public function GetCellTop( parX: int, parY: int ): Point
		{
			return new Point( ( parY - parX ) * this._CellProjectionWidthHalf,
				( parY + parX ) * this._CellProjectionHeightHalf );
		} // GetCellTop
		
		/**
		 * Возвращает центр ячейки. Ячейка - это изометрический квадрат
		 * размером 1x1 в клетках, проекция которого - ромб.
		 * @param parX Индекс по оси абсцисс раположения клетки от нуля.
		 * @param parY Индекс по оси ординат раположения клетки от нуля.
		 * @return Середина клетки, заданной индексами клетки по осям OX и OY.
		 */
		public function GetCellCenter( parX: int, parY: int ): Point
		{
			return new Point( ( parY - parX ) * this._CellProjectionWidthHalf,
				( parY + parX + 1 ) * this._CellProjectionHeightHalf );
		} // GetCellCenter		
		
		/**
		 * Возврат изометрического прямоугольника с координатами в пикселях
		 * относительно объекта-контейнера. Заданы индексы расположения
		 * верхней клетки прямоугольника по осям OX и OY, а также величины
		 * сторон в клетках. Полагается, что координаты относительно
		 * объекта-контейнера самого начала координат в заданной
		 * системе координат - ( 0; 0 ).
		 * @param parTopX Индекс по оси абсцисс раположения верхней клетки
		 * изометрического прямоугольника, от нуля.
		 * @param parTopY Индекс по оси ординат раположения верхней клетки
		 * изометрического прямоугольника, от нуля.
		 * @param parXSide Сторона по оси OX в клетках.
		 * @param parYSide Сторона по оси OY в клетках.		
		 * @return Изометрический прямоугольник.
		 */
		public function GetIsometricParallelToXOYRectangle( parTopX: int,
			parTopY: int, parXSide: int, parYSide: int )
			: IsometricParallelToXOYRectangle
		{
			return new IsometricParallelToXOYRectangle
				( this.GetCellTop( parTopX, parTopY ),
				parXSide * this._CellSide, parYSide * this._CellSide );
		} // GetIsometricParallelToXOYRectangle
		
		/**
		 * Возврат изометрического квадрата с координатами в пикселях
		 * относительно объекта-контейнера. Заданы индексы расположения
		 * верхней клетки квадрата по осям OX и OY, а также величина
		 * стороны в клетках. Полагается, что координаты относительно
		 * объекта-контейнера самого начала координат в заданной
		 * системе координат - ( 0; 0 ).
		 * @param parTopX Индекс по оси абсцисс раположения верхней клетки
		 * изометрического квадрата, от нуля.
		 * @param parTopY Индекс по оси ординат раположения верхней клетки
		 * изометрического квадрата, от нуля.
		 * @param parSide Сторона в клетках.		
		 * @return Изометрический квадрат.
		 */
		public function GetIsometricXOYSquare( parTopX: int, parTopY: int,
			parSide: int ): IsometricParallelToXOYSquare
		{
			return new IsometricParallelToXOYSquare
				( this.GetCellTop( parTopX, parTopY ), parSide * this._CellSide );
		} // GetIsometricXOYSquare
		
		/**
		 * Сторона клетки изметрической сетки в пикселях.
		 * @return Сторона клетки изметрической сетки в пикселях.
		 */		
		public function get CellSide( ): Number
    { 
			return this._CellSide;
		}	// get CellSide		
	} // IsometricXOYGrid
} // geom
