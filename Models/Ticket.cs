using System;
using System.ComponentModel.DataAnnotations;

namespace ProyectoDS1.Models
{
    public class Ticket
    {
        [Key]
        public int IdTicket { get; set; }

        [Display(Name = "Título")]
        [Required(ErrorMessage = "El título es obligatorio")]
        [StringLength(150)]
        public string Titulo { get; set; }

        [Required]
        [Display(Name = "Descripción")]
        public string Descripcion { get; set; } = string.Empty;

        [Display(Name = "Fecha")]
        public DateTime FechaCreacion { get; set; }

        [Display(Name = "Fecha Cierre")]
        public DateTime? FechaCierre { get; set; }

        [Display(Name = "Usuario")]
        public string UsuarioCreador { get; set; }

        [Display(Name = "Estado")]
        public string Estado { get; set; }

        [Display(Name = "Prioridad")]
        public string Prioridad { get; set; }

        [Display(Name = "Categoría")]
        public string Categoria { get; set; }

        // === IDs para inserción ===
        [Required]
        [Display(Name = "Estado")]
        public int IdEstado { get; set; }
        [Required]
        [Display(Name = "Prioridad")]
        public int IdPrioridad { get; set; }

        [Required]
        [Display(Name = "Categoría")]
        public int IdCategoria { get; set; }

        // por ahora fijo
        public int IdUsuarioCreador { get; set; } = 1;


        public Ticket()
        {
            Titulo = "";
            Descripcion = "";
            UsuarioCreador = "";
            Estado = "";
            Prioridad = "";
            Categoria = "";
        }
    }
}