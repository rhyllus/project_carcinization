using Godot;

public partial class playerfundamentals : Node3D
{	
	public int GravityMagnitude = (int)ProjectSettings.GetSetting("physics/3d/default_gravity");
	[Export]
	public float Speed = 5000.0f;
	[Export]
	public float Acceleration = 50.0f; 
	[Export]
	public float Deceleration = 50.0f;
	public enum PlayerStates {Flying, Grounded, Breaking, Action, Impulse}; 
	public PlayerStates PlayerState = PlayerStates.Flying;
	public enum ImpulseStates {None, NoGravity, NoInput, AllDisabled}; 
	public ImpulseStates ImpulseState = ImpulseStates.None;
	public CharacterBody3D CharacterBody;
	public Vector3 CBodyVelocityCopy;
	public CollisionShape3D MainCollisionShape;
	public MeshInstance3D DefaultMesh;
	public Node3D RotationHandler;
	public override void _Ready()
	{
		attach_node_references();
	}
	public void Impulse(float strength, Vector3 direction, bool disableGravity, bool disableInput)
	{
		CharacterBody.Velocity = direction * strength;
	}

	private void attach_node_references()
	{
		CharacterBody = GetNode<CharacterBody3D>("CharacterBody3D");
		MainCollisionShape = CharacterBody.GetNode<CollisionShape3D>("CollisionShape3D");
		DefaultMesh = CharacterBody.GetNode<MeshInstance3D>("MeshInstance3D");
		RotationHandler = CharacterBody.GetNode<Node3D>("RotationHandler");
	}
}
