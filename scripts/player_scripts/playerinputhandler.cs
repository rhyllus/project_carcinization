using Godot;

public partial class playerinputhandler : playercollisionhandler
{
    private Vector2 input_vect2;
	public Vector3 get_horizontal_input()
    {
        input_vect2 = Input.GetVector("left", "right", "forward", "back");
        return new Vector3(input_vect2.X, 0.0f, input_vect2.Y) * RotationHandler.Transform.Inverse();
    }
}

