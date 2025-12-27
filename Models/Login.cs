using System.ComponentModel.DataAnnotations;

namespace ProyectoDS1.Models
{
    public class Login
    {
        [Required(ErrorMessage = "El Correo es obligatorio")]
        [Display(Name = "Correo electrónico")]
        public string Email { get; set; }

        [Required(ErrorMessage = "La contraseña es obligatorio")]
        [DataType(DataType.Password)]
        [Display(Name = "Contraseña")]
        public string Contrasena { get; set; }
    }
}
