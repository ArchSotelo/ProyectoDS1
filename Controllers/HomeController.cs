using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using ProyectoDS1.Models;
using System.Data;
using System.Diagnostics;
using System.Text.Json;

namespace ProyectoDS1.Controllers
{
    public class HomeController : Controller
    {
        private readonly IConfiguration _config;
        private readonly ILogger<HomeController> _logger;

        public HomeController(IConfiguration config, ILogger<HomeController> logger)
        {
            _config = config;
            _logger = logger;
        }

        public async Task<IActionResult> Index()
        {
            var usuarioJson = HttpContext.Session.GetString("UsuarioSesion");
            if (usuarioJson == null)
                return RedirectToAction("Login", "Login");

            var usuario = JsonSerializer.Deserialize<UsuarioSession>(usuarioJson);

            var model = new DashboardViewModel
            {
                Usuario = usuario,
            };

            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                await cn.OpenAsync();

                if (usuario.IdRol == 1 || usuario.IdRol == 2)
                {
                    SqlCommand cmd = new SqlCommand("usp_DashboardTotales", cn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    using var dr = await cmd.ExecuteReaderAsync();
                    if (await dr.ReadAsync())
                    {
                        model.Abiertos = Convert.ToInt32(dr["Abiertos"]);
                        model.EnProceso = Convert.ToInt32(dr["EnProceso"]);
                        model.Cerrados = Convert.ToInt32(dr["Cerrados"]);
                        model.Total = Convert.ToInt32(dr["Total"]);
                    }
                    dr.Close();
                }
            }

            return View(model);
        }

    

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
