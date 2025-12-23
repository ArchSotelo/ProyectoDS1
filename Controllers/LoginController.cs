using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using ProyectoDS1.Models;
using System.Data;

namespace ProyectoDS1.Controllers
{
    public class LoginController : Controller
    {
        private readonly IConfiguration _config;

        public LoginController(IConfiguration config)
        {
            _config = config;
        }


        [HttpGet]
        public IActionResult Login()
        {
            return View(new Login());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(Login model)
        {
            if (!ModelState.IsValid)
                return View(model);

            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                await cn.OpenAsync();
                SqlCommand cmd = new SqlCommand("usp_VerificarUsuario", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Email", model.Email);
                cmd.Parameters.AddWithValue("@ContrasenaHash", model.Contrasena);
                var result = await cmd.ExecuteScalarAsync();

                if (result != null)
                {

                    HttpContext.Session.SetString("usuario", model.Email);

                    return RedirectToAction("Index", "Home");

                }
                else
                {
                    ViewBag.mensaje = "Credenciales incorrectas";
                    return View(model);
                }
            }
        }

    }
}
