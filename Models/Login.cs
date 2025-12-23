using System.ComponentModel.DataAnnotations;

namespace ProyectoDS1.Models
{
    public class Login
    {
        [Required]
        [Display(Name = "Correo electrónico")]
        public string Email { get; set; }

        [Required]
        [DataType(DataType.Password)]
        [Display(Name = "Contraseña")]
        public string Contrasena { get; set; }
    }
}
