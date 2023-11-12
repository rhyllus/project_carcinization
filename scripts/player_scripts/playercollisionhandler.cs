using Godot;

public partial class playercollisionhandler : playerfundamentals
{
	private Basis new_basis;
	public Basis normal_to_new_basis(Vector3 normal)
	{
		new_basis = new Basis(new Quaternion(Vector3.Up, normal));
		return new_basis;
	}
}
