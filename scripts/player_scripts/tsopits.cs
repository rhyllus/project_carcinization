using Godot;

public partial class tsopits : playerbehaviours
{
	public override void _PhysicsProcess(double delta)
	{
		CBodyVelocityCopy = CharacterBody.Velocity;
		if (PlayerState == PlayerStates.Flying)
		{
			if (CharacterBody.IsOnFloor())
			{
				PlayerState = PlayerStates.Grounded;
			}
			else
			{
				CharacterBody.Velocity = new Vector3(CBodyVelocityCopy.X, CBodyVelocityCopy.Y - (GravityMagnitude * (float)delta), CBodyVelocityCopy.Z);
			}
		}
		if (PlayerState == PlayerStates.Grounded)
		{
			ground_movement(delta);
		}
		CharacterBody.MoveAndSlide();
	}
}
