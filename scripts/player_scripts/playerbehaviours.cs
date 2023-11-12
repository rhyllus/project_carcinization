using Godot;

public partial class playerbehaviours : playerinputhandler
{	
    public enum PlayerActionStates {Punching, Shooting};
    public void ground_movement(double delta)
    {
        CharacterBody.Velocity = get_horizontal_input() * (Speed * (float)delta); 
    }
}
