/**
 * Пакет логических представлений игровых объектов.
 */
package hillyLandscape.model
{
	import enumerations.StringEnumeration;
	
	/**
	 * Класс типа вертикальной грани между тайлами.
	 * Положение тайлов может изменяться по высоте. Их координаты и индексы
	 * по осям OX и OY при этом не изменяются. Тогда, если соединить
	 * смежные тайлы, будут видны вертикальные грани, параллельные
	 * координатным плоскостям YOZ и XOZ.
	 * Грани, параллельные YOZ, возникают между тайлами в соседних столбцах,
	 * расположенных в ячейках по оси OX (ось направлена от цента влево-вниз).
	 * Грани, параллельные XOZ, возникают между тайлами в соседних строках,
	 * расположенных в ячейках по оси OY (ось направлена от цента вправо-вниз).
	 */
	public final class VerticalFaceType extends StringEnumeration
	{
		/**
		 * Грань, параллельная XOZ.
		 */
		public static const XOZ_PARALLEL: VerticalFaceType
			= new VerticalFaceType( "XOZ_PARALLEL" );
		/**
		 * Грань, параллельная YOZ.
		 */
		public static const YOZ_PARALLEL: VerticalFaceType
			= new VerticalFaceType( "YOZ_PARALLEL" );
			
		/**
		 * Конструктор типа плиточного замещения ландшафта.
		 * @param parValue Значение текущего элемента.
		 */
		public function VerticalFaceType( parValue: String )
		{
			this.Value = parValue;
		} // VerticalFaceType			
	} // VerticalFaceType
} // hillyLandscape.model