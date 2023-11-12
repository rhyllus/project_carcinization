using Godot;

public partial class tsopits : playerbehaviours
{
	public override void _PhysicsProcess(double delta)
	{
		CBodyVelocityCopy = CharacterBody.Velocity;
		if (PlayerState == PlayerStates.Flying)
		{
			GD.Print(CBodyVelocityCopy.Y);
			CharacterBody.Velocity = new Vector3(CBodyVelocityCopy.X, CBodyVelocityCopy.Y - (GravityMagnitude * (float)delta), CBodyVelocityCopy.Z);
		}
		CharacterBody.MoveAndSlide();
	}
}
