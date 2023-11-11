using Godot;

public partial class playerfundamentals : Node3D
{	
	[Export]
	public float SPEED = 50.0f;
	[Export]
	public float ACCELERATION = 50.0f; 
	[Export]
	public float DECELERATION = 50.0f; 
	public CharacterBody3D CharacterBody;
	public CollisionShape3D MainCollisionShape;
	public MeshInstance3D DefaultMesh;
	public Node3D RotationHandler;
	public override void _Ready()
	{
		CharacterBody = GetNode<CharacterBody3D>("CharacterBody3D");
		MainCollisionShape = CharacterBody.GetNode<CollisionShape3D>("CollisionShape3D");
		DefaultMesh = CharacterBody.GetNode<MeshInstance3D>("MeshInstance3D");
		RotationHandler = CharacterBody.GetNode<Node3D>("RotationHandler");
	}
	public void Impulse(float Strength, bool DisableGravity)
	{
		GD.Print("sex");
	}
}
