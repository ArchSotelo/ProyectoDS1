using System.ComponentModel.DataAnnotations;

namespace ProyectoDS1.Models
{
    public class Usuario
    {
        [Key]public int idUsuario {  get; set; }

        [Display(Name = "Codigo")]
        [Required(ErrorMessage = "El código es obligatorio")]
        public string codigoUsuario { get; set; }

        [Display(Name = "Nombre")]
        [Required(ErrorMessage = "El nombre es obligatorio")]
        [StringLength(50, ErrorMessage = "Máximo 50 caracteres")]
        public string nombreUsuario { get; set; }

        [Display(Name = "Apellido")]
        [Required(ErrorMessage = "El apellido es obligatorio")]
        public string apellidoUsuario { get; set; }

        [Display(Name = "Email")]
        [Required(ErrorMessage = "El email es obligatorio")]
        [EmailAddress(ErrorMessage = "Formato de correo inválido")] 
        public string email {  get; set; }

        [Display(Name = "Telefono")]
        [Required(ErrorMessage = "El telefono es obligatorio")]
        [Phone(ErrorMessage = "Formato de teléfono inválido")]
        public string telefono { get; set; }

        [Display(Name = "Contraseña")]
        [Required(ErrorMessage = "La contraseña es obligatoria")]
        [StringLength(20, MinimumLength = 6, ErrorMessage = "Debe tener entre 6 y 20 caracteres")] 
        public string contrasena { get; set; }

        [Display(Name = "Rol")]
        [Required(ErrorMessage = "Debe seleccionar un rol")] 
        public int idRol { get; set; }

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
            Activo = true;
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
