namespace ProyectoDS1.Models
{
    public class DashboardViewModel
    {
        public int Abiertos { get; set; }
        public int EnProceso { get; set; }
        public int Cerrados { get; set; }
        public int Total { get; set; }

        public UsuarioSession Usuario { get; set; }
    }
}
