/// @description Insert description here
// You can write your code in this editor
with (other)
{
	damage_sys.Heal(other.amount);
}

    var popup = instance_create_depth(x, y - 60, -9999, obj_floating_text);
    popup.text = "+10HP!";
    popup.color = c_green;
    popup.lifetime = 120;
    popup.rise_speed = 0.5;
    popup.scale = 2.0;


instance_destroy();