using System.ComponentModel.DataAnnotations;

namespace ProyectoDS1.Models
{
    public class Usuario
    {
        [Key]public int idUsuario {  get; set; }

        [Required, Display(Name = "Nombre")]public string nombreUsuario { get; set; }

        [Required, Display(Name = "Email")] public string email {  get; set; }

        [Required, Display(Name = "Contraseña")] public string contrasena { get; set; }

        [Required, Display(Name = "Rol")] public int idRol { get; set; }
        public string nombreRol { get; set; }

        [Display(Name = "Estado")] public Boolean Activo { get; set; }


        public Usuario() {

            nombreRol = "";
            email = "";
            contrasena = "";
            nombreRol = "";
        }

    }
}
