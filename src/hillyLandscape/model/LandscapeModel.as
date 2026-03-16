/**
 * Пакет логических представлений игровых объектов.
 */
package hillyLandscape.model
{
	import enumerations.Enumeration;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import geom.CellLocation;
	import geom.IsometricParallelToXOYSquare;
	import geom.IsometricXOYGrid;

	/**
	 * Логическое представление холмистого ландшафта.
	 * В стандартной ортогональной изометрической проекции начало координат -
	 * в центре. Аксонометрические оси образуют между собой углы в 120 градусов.
	 * Ось аппликат направлена снизу вверх, поэтому все вертикально направленные
	 * линии параллельны ей.
	 * Ось абсцисс от начала координат направлена влево-вниз, поэтому линии,
	 * параллельные ей имеют направление слева-снизу вправо-вверх и наоборот.
	 * Ось ординат от начала координат направлена враво-вниз, поэтому линии,
	 * параллельные ей имеют направление справа-снизу влево-вверх и наоборот.
	 * Каждый тайл располагается в плоскости параллельно плоскости XOY.
	 * Вначале любой тайл, находится в координатной плоскости XOY,
	 * разделённой сеткой. Одну ячейку кординатной сети занимает один тайл.
	 * Ячейки сетки пронумерованы целочисленными индексами от нуля.
	 * Два индекса соответствуют положению тайла в строке по оси OY
	 * и в столбце по оси OX. Самый первый тайл имеет координаты ячейки [0,0].
	 * Информация о тайлах хранится в матрице - двумерном массиве,
	 * инексы строк и столбцов которого соответствуют номерам ячеек
	 * размещения тайлов в плоскостях, разделённых сетками и параллельными
	 * плоскости XOY.
	 * О тайлах хранится следующая информация: тип и высота.
	 * Положение тайла может измениться по высоте - координата по оси OZ,
	 * которая представляется в пикселях, в отличае от абсциссы и ординаты,
	 * заданных в клетках. 
	 */
	public class LandscapeModel extends EventDispatcher
	{
		/**
		 * Название типа события устновки размещений тайлов на ландшафте. 
		 */
		public static const LOCATIONS_ARE_SET: String = "LocationsAreSet";
		
		/**
		 * Размещения тайлов на ландшафте переменной высоты.
		 */
		private var _Locations: TilesLocations = new TilesLocations( );
		/**
		 * Локальная изометрическая сетка, начало координат в пикселях которой -
		 * точка (0; 0).
		 */
		private var _Grid: IsometricXOYGrid = new IsometricXOYGrid( );
		/**
		 * Точка объекта-контейнера, в которой находится локальное начало координат.
		 * Координаты изометрического начала координат - координаты
		 * самого верхнего угла самого верхнего квадратика из тех,
		 * на которые делится координатная плоскость XOY.
		 */
		private var _IsometricOrigin: Point = new Point( );
		/**
		 * Изометрические квадраты в кооринатах объекта-контейнера -
		 * координаты в пикселях изометрических проекций ячеек, заняых тайлами.
		 * Каждая ячейка имеет индексы размещения по осям абсцисс и ординат -
		 * инексы клетки, а также высоту - координату по оси аппликат в пикселях.
		 * Двумерная проекция имеет две координаты в пикселях: абсциссу и ординату
		 * в системе координат объекта-контейнера.
		 */
		private var _IsometricLocations
			: Vector.< Vector.< IsometricParallelToXOYSquare > > =
			new Vector.< Vector.< IsometricParallelToXOYSquare > >( );
			
		/**
		 * Конструктор длгического представления холмистого ландшафта.
		 * @param parIsometricOrigin Изометрическое начало координат -
		 * коорданиты самого верхнего угла самого верхнего квадратика из тех,
		 * на которые делится координатная плоскость XOY.
		 * @param parGrid Локальная изометрическая сетка. 
		 */
		public function LandscapeModel( parIsometricOrigin: Point,
			parGrid: IsometricXOYGrid ): void
		{
			if ( parIsometricOrigin != null )
				this._IsometricOrigin = parIsometricOrigin;
			if ( parGrid != null )
				this._Grid = parGrid;
			// Уже проинициализировано:
			// private var _Locations: TilesLocations = TilesLocations( );
			this.SetLocations( );
			// Регистрирация объекта-прослушивателя события
			// успешной загрузки XML-файла размещения тайлов
			// на ландшафте переменной высоты.
			this._Locations.addEventListener( TilesLocations.XML_FILE_LOADING_COMPLETE,
				this.LocationsLoadingCompleteListener );			
		} // LandscapeModel
		
		/**
		 * Метод-прослушиватель события успешной загрузки XML-файла
		 * размещения тайлов на ландшафте переменной высоты.
		 * @param parEvent Событие.
		 */
		private function LocationsLoadingCompleteListener( parEvent: Event ): void
		{		
			// Файл загрузился - ландшафт поменялся, значит,
			// нужнообновить размещения тайлов.
			this.SetLocations( );
		} // LocationsLoadingCompleteListener
		
		/**
		 * Метод установки изометрических квадратов тайлов в кооринатах
		 * объекта-контейнера по заданной матрице размещений тайлов.
		 */
		private function SetLocations( ): void
		{
			// Изометрические координаты очищаются.
			this._IsometricLocations
				= new Vector.< Vector.< IsometricParallelToXOYSquare > >( );
			
			for ( var yRow: uint = 0; yRow < this._Locations.YRowsCount; yRow++ )
			{		
				this._IsometricLocations[ yRow ]
					= new Vector.< IsometricParallelToXOYSquare >( );
				for ( var xColumn: uint = 0; xColumn < this._Locations.XColumnsCount;
						xColumn++ )
					this._IsometricLocations[ yRow ][ xColumn ]
						= IsometricParallelToXOYSquare
						(
							new IsometricParallelToXOYSquare
							(
								this._Grid.GetCellTop( xColumn, yRow ),
								this._Grid.CellSide
							) //  new IsometricParallelToXOYSquare
							.GetMoved
							(
								new Point
								(
									this._IsometricOrigin.x,
									this._IsometricOrigin.y
										- this._Locations.Locations[ yRow ][ xColumn ].Z
								) // new Point
							) // GetMoved
						); // IsometricParallelToXOYSquare
			} // for ( var yRow...
			
			// Передача события устновки размещений тайлов на ландшафте
			// в поток событий, целью - объбектом-получателем - которого
			// является данная логическая модель ландшафта.
			this.dispatchEvent( new Event( LandscapeModel.LOCATIONS_ARE_SET ) );
		} // SetLocations
		
		/**
		 * Перемещение тайла с заданными индексами матрицы по оси аппликат.
		 * @param parYRow Индекс строки размещения ячейки тайла по оси OY.
		 * @param parXColumn Индекс столбца размещения ячейки тайла по оси OX.
		 * @param parZOffset Смещение по оси OZ.
		 * @return Реальное смещение, которое произошло для данного тайла по оси OZ:
		 * заданы предельные границы значения высоты расположения тайла по оси OZ,
		 * нарушать которые нельзя.
		 */
		public function MoveZ( parYRow: uint, parXColumn: uint, parZOffset: Number )
			: Number
		{
			// Логическое преставление тайла совершает перемещение по аппликате.
			// Величина смещения корректируется, согласно установленным границам.
			parZOffset = this._Locations.MoveZ( parYRow, parXColumn, parZOffset );
			// Теперь перемещается проекция днного тайла на плоскости
			// объекта-контейнера. В изометрической проекции ось OZ направлена
			// вертикально снизу вверх. В координатной системе объекта-контейнера
			// вертикально направлена ось OY, которая, наоборот, идёт сверху вниз,
			// поэтому перемещение берётся с противоположным знаком.
			this._IsometricLocations[ parYRow ][ parXColumn ].MoveY( -parZOffset );
			// Передача события перемещения тайла по оси OZ в поток событий, целью -
			// объбектом-получателем - которого является данная модель ландшафта.
			this.dispatchEvent( new TileEvent( TileEvent.TILE_Z_MOVEMENT, parYRow,
				parXColumn, this._Locations.Locations[ parYRow ][ parXColumn ].Z,
				parZOffset ) );			
			return parZOffset;
		} // MoveZ
		
		/**
		 * Получение индексов тайла, в пределах которого лежит заданная точка
		 * в координатах объекта-контейнера.
		 * @param parPoint Заданная точка в координатах контейнера.
		 * @return Размещение тайла: инексы строки и столбца размещения его ячейки
		 * в плоскости, параллельноой XOY.
		 */	
		public function GetCellLocationIfContains( parPoint: Point )
			: CellLocation
		{
			// Просмотр будет проходить по диагоналям, потому что существуют
			// задние и передине планы. Смотрим, начиная с передних планов.
			
			// Количество строк матрицы.
			const Y_ROWS_COUNT: uint = this._Locations.YRowsCount;
			// Количество столбцов матрицы матрицы.
			const X_COLUMNS_COUNT: uint = this._Locations.XColumnsCount;			
			// Количество просматриваемых диагоналей.
			const DIAGONALS_COUNT: uint = X_COLUMNS_COUNT + Y_ROWS_COUNT - 1;
			
			// По диагоналям, которые расположены горизонтально на сцене,
			// идём сверху вних от верхней точки дома, где находится начало координат.
			for ( var diagonalIndex: int = DIAGONALS_COUNT - 1; diagonalIndex >= 0;
					diagonalIndex-- )
				// Проходим текущую диагональ справа-налево: для перехода
				// по клеткам побочной диагонали ордината уменьшается,
				// а абсцисса растёт.
				for ( var yRow: int = Math.min( diagonalIndex, Y_ROWS_COUNT - 1 ),
						xColumn: int = diagonalIndex - yRow;
						( yRow >= 0 ) && ( xColumn < X_COLUMNS_COUNT );
						yRow--, xColumn++ )				
					if ( this._IsometricLocations[ yRow ][ xColumn ].Contains( parPoint ) )
						return new CellLocation( yRow, xColumn );
			
			// Вот так будет приоритет у задних планов, а нам однозначно
			// нужны передние планы, особенно, когда идёт загораживание.
			/*for ( var yRow: uint = 0; yRow < this._Locations.YRowsCount; yRow++ )
				for ( var xColumn: uint = 0; xColumn < this._Locations.XColumnsCount;
						xColumn++ )
					if ( this._IsometricLocations[ yRow ][ xColumn ].Contains( parPoint ) )
						return new CellLocation( yRow, xColumn );*/
					
			// Если точка объекта-контейнера не попадает ни на один тайл.
			return null;					
		} // GetCellLocationIfContains
		
		/**
		 * Возвращает строковое представление заданного объекта.
		 * Только в методе toString я всегда использую строковые значения в лоб
		 * без помещения их в качестве констант класса.
		 * @return Строковое представление объекта.
		 */
		public override function toString( ): String
		{
			var result: String = "LandscapeModel:";
			for ( var yRow: uint = 0; yRow < this._Locations.YRowsCount; yRow++ )
			{		
				result += "\nRow #" + yRow + ":";
				for ( var xColumn: uint = 0; xColumn < this._Locations.XColumnsCount;
						xColumn++ )
					result += "\n\tColumn #" + xColumn + ":"
						+ "\n\t\tTop: " + this._IsometricLocations[ yRow ][ xColumn ]
							.TopAndLocalOrigin.toString( )
						+ "\n\t\tRight: " + this._IsometricLocations[ yRow ][ xColumn ]
							.Right.toString( )
						+ "\n\t\tBottom: " + this._IsometricLocations[ yRow ][ xColumn ]
							.Bottom.toString( )
						+ "\n\t\tLeft: " + this._IsometricLocations[ yRow ][ xColumn ]
							.Left.toString( );
			} // for ( var yRow...
			
			return result;
		} // toString
		
		/**
		 * Локальная изометрическая сетка, начало координат в пикселях которой -
		 * точка (0; 0).
		 * @return Локальная изометрическая сетка, начало координат
		 * в пикселях которой - точка (0; 0).
		 */		
		public function get Grid( ): IsometricXOYGrid
    { 
        return this._Grid; 
    }	// get Grid		
		
		/**
		 * Размещения тайлов на ландшафте переменной высоты.
		 * @return Размещения тайлов на ландшафте переменной высоты.
		 */		
		public function get Locations( ): TilesLocations
    { 
        return this._Locations; 
    }	// get Locations				
		
		/**
		 * Изометрические квадраты в кооринатах объекта-контейнера -
		 * координаты в пикселях изометрических проекций ячеек, заняых тайлами.
		 * Каждая ячейка имеет индексы размещения по осям абсцисс и ординат -
		 * инексы клетки, а также высоту - координату по оси аппликат в пикселях.
		 * Двумерная проекция имеет две координаты в пикселях: абсциссу и ординату
		 * в системе координат объекта-контейнера.
		 * @return Матрица координат в пикселях относительно объекта-контейнера
		 * размещении тайлов ландшафта.
		 */		
		public function get IsometricLocations( )
			: Vector.< Vector.< IsometricParallelToXOYSquare > >
    { 
        return this._IsometricLocations; 
    }	// get IsometricLocations			
	} // LandscapeModel	
} // hillyLandscape.model
