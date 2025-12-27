using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using ProyectoDS1.Models;
using System.Data;
using System.Text.Json;

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

                using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        var usuarioSesion = new UsuarioSession
                        {
                            IdUsuario = Convert.ToInt32(reader["IdUsuario"]),
                            NombreCompleto = $"{reader["Nombre"]} {reader["Apellido"]}",
                            IdRol = Convert.ToInt32(reader["IdRol"])
                        };

                        HttpContext.Session.SetString(
                            "UsuarioSesion",
                            JsonSerializer.Serialize(usuarioSesion)
                        );

                        TempData["Bienvenida"] = $"Bienvenido {usuarioSesion.NombreCompleto}!";

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

        public IActionResult Logout()
        {
            // Elimina toda la sesión
            HttpContext.Session.Clear();

            // Evita volver con botón "Atrás"
            Response.Headers["Cache-Control"] = "no-cache, no-store, must-revalidate";
            Response.Headers["Pragma"] = "no-cache";
            Response.Headers["Expires"] = "0";

            return RedirectToAction("Login", "Login");
        }

    }
}
