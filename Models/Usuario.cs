using System.ComponentModel.DataAnnotations;

namespace ProyectoDS1.Models
{
    public class Usuario
    {
        [Key]public int idUsuario {  get; set; }

        [Required, Display(Name = "Codigo")] public string codigoUsuario { get; set; }

        [Required, Display(Name = "Nombre")]public string nombreUsuario { get; set; }

        [Required, Display(Name = "Apellido")] public string apellidoUsuario { get; set; }

        [Required, Display(Name = "Email")] public string email {  get; set; }

        [Required, Display(Name = "Telefono")] public string telefono { get; set; }

        [Required, Display(Name = "Contraseña")] public string contrasena { get; set; }

        [Required, Display(Name = "Rol")] public int idRol { get; set; }

        public string nombreRol { get; set; }

        [Display(Name = "Estado")] public Boolean Activo { get; set; }

        public Usuario()
        {

            codigoUsuario = "";
            nombreUsuario = "";
            apellidoUsuario = "";
            email = "";
            telefono = "";
            contrasena = "";
            nombreRol = "";
        }

        public string estadoUsuario(){
            if (Activo == true)
                return "Activo";
            else
                return "Inactivo";
        }

        public string nombreCompleto()
        {
            return nombreUsuario + " " + apellidoUsuario;
        }

        



    }
}
