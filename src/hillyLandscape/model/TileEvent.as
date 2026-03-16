/**
 * Пакет логических представлений игровых объектов.
 */
package hillyLandscape.model
{ 
	import flash.events.Event;

	/**
	 * Класс события тайла.
	 */
	public class TileEvent extends Event
	{
		/**
		 * Название типа события перемещения тайла по оси OZ.
		 */
		public static const TILE_Z_MOVEMENT: String = "TileZMovement";
		/**
		 * Индекс строки размещения ячейки тайла по оси OY.
		 */
		private var _YRow: uint = 0;
		/**
		 * Индекс столбца размещения ячейки тайла по оси OX.
		 */
		private var _XColumn: uint = 0;
		/**
		 * Высота по оси OZ.
		 */
		private var _ZHeight: Number = 0;
		/**
		 * Смещение по оси OZ.
		 */
		private var _ZOffset: Number = 0;
		
		/**
		 * Метод-конструктор экземпляра события тайла.
		 * @param parType Тип события.
		 * @param parYRow Индекс строки размещения ячейки тайла по оси OY.
		 * @param parXColumn Индекс столбца размещения ячейки тайла по оси OX.
		 * @param parZHeight Высота по оси OZ.
		 * @param parZOffset Смещение по оси OZ.
		 * @param parBubbles Признак участия события на этапе восходящей цепочки
		 * процесса события.
		 * @param parCancelable Признак возможности отмены события.
		 */
		public function TileEvent
		(
			parType: String,
			parYRow: uint = 0,
			parXColumn: uint = 0,
			parZHeight: Number = 0,
			parZOffset: Number = 0,
			parBubbles: Boolean = false,
			parCancelable: Boolean = false
		): void
		{
			// Вызов метода-конструктора суперкласса Event.
			super( parType, parBubbles, parCancelable );
			
			this._YRow = parYRow;
			this._XColumn = parXColumn;
			this._ZHeight = parZHeight;
			this._ZOffset = parZOffset;
		} // TileEvent		
		
		/**
		 * Метод, создающий копию объекта события тайла и задающий значение
		 * каждого свойства, совпадающее с оригиналом.
		 * @return Новый объект события тайла, значения свойств которого
		 * соответствуют значениям оригинала.
		 */
		public override function clone( ): Event
		{
			// Создание экземпляра события тайла.
			return new TileEvent
			(
				this.type,
				this._YRow,
				this._XColumn,
				this._ZHeight,
				this._ZOffset,
				this.bubbles,
				this.cancelable
			); // return
		} // clone
		
		/**
		 * Метод получения строки, содержащей все свойства объекта события тайла.
		 * @return Строка, содержащая все свойства объекта события тайла.
		 */
		public override function toString( ): String
		{ 
			// Служебная функция для реализации метода toString( )
			// в пользовательских классах для вывода всех свойств,
			// где eventPhase - текущая фаза в потоке событий.
			return formatToString
			(
			 	"TileEvent",
				"type",
				"YRow",
				"XColumn",
				"ZHeight",
				"ZOffset",	
				"bubbles",
				"cancelable"
			); // return 
		}	// toString	
		
		/**
		 * Индекс строки размещения ячейки тайла по оси OY.
		 * @return Индекс строки размещения ячейки тайла по оси OY.
		 */		
		public function get YRow( ): uint
    { 
    	return this._YRow;
		}	// get YRow
		
		/**
		 * Индекс столбца размещения ячейки тайла по оси OX.
		 * @return Индекс столбца размещения ячейки тайла по оси OX.
		 */		
		public function get XColumn( ): uint
    { 
    	return this._XColumn;
		}	// get XColumn
		
		/**
		 * Высота по оси OZ.
		 * @return Высота по оси OZ.
		 */		
		public function get ZHeight( ): Number
    { 
    	return this._ZHeight;
		}	// get ZHeight		
		
		/**
		 * Смещение по оси OZ.
		 * @return Смещение по оси OZ.
		 */		
		public function get ZOffset( ): Number
    { 
    	return this._ZOffset;
		}	// get ZOffset		
	} // TileEvent
} // hillyLandscape.model