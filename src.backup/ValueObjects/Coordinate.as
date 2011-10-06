package ValueObjects
{
	public class Coordinate
	{
		private var _gridX:int;
		private var _gridY:int;
		public function Coordinate( tgridX:int = 0, tgridY:int = 0)
		{
			_gridX = tgridX;
			_gridY = tgridY;
		}

		public function get gridY():int
		{
			return _gridY;
		}

		public function set gridY(value:int):void
		{
			_gridY = value;
		}

		public function get gridX():int
		{
			return _gridX;
		}

		public function set gridX(value:int):void
		{
			_gridX = value;
		}

	}
}