using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using ProyectoDS1.Models;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.Blazor;

namespace ProyectoDS1.Controllers
{
    public class UsuariosController : Controller
    {
        private readonly IConfiguration _config;

        public UsuariosController(IConfiguration config)
        {
            _config = config;
        }

        // Listar usuarios
        private async Task<IEnumerable<Usuario>> listarUsuarios()
        {
            var temporal = new List<Usuario>();
            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                await cn.OpenAsync();
                using (SqlCommand cmd = new SqlCommand("usp_ListarUsuario", cn))
                using (SqlDataReader dr = await cmd.ExecuteReaderAsync())
                {
                    while (await dr.ReadAsync())
                    {
                        temporal.Add(new Usuario()
                        {
                            idUsuario = dr.GetInt32(0),
                            codigoUsuario = dr.GetString(1),
                            nombreUsuario = dr.GetString(2),
                            apellidoUsuario = dr.GetString(3),
                            email = dr.GetString(4),
                            telefono = dr.GetString(5),
                            contrasena = dr.GetString(6),
                            idRol = dr.GetInt32(7),
                            nombreRol = dr.GetString(8),
                            Activo = dr.GetBoolean(9)
                        });
                    }
                }
            }
            return temporal;
        }

        // Listar roles
        private async Task<IEnumerable<Rol>> listarRol()
        {
            var temporal = new List<Rol>();
            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                await cn.OpenAsync();
                using (SqlCommand cmd = new SqlCommand("usp_ListarRol", cn))
                using (SqlDataReader dr = await cmd.ExecuteReaderAsync())
                {
                    while (await dr.ReadAsync())
                    {
                        temporal.Add(new Rol()
                        {
                            idRol = dr.GetInt32(0),
                            nombreRol = dr.GetString(1),
                        });
                    }
                }
            }
            return temporal;
        }

        // Insertar usuario
        private async Task<(bool exito, string mensaje)> NuevoUsuario(Usuario reg)
        {
            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_InsertarUsuario", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Codigo", reg.codigoUsuario);
                    cmd.Parameters.AddWithValue("@Nombre", reg.nombreUsuario);
                    cmd.Parameters.AddWithValue("@Apellido", reg.apellidoUsuario);
                    cmd.Parameters.AddWithValue("@Email", reg.email);
                    cmd.Parameters.AddWithValue("@Telefono", reg.telefono);
                    cmd.Parameters.AddWithValue("@Contrasena", reg.contrasena);
                    cmd.Parameters.AddWithValue("@Rol", reg.idRol);
                    cmd.Parameters.AddWithValue("@Activo", reg.Activo);

                    await cn.OpenAsync();
                    await cmd.ExecuteNonQueryAsync();
                    return (true, $"Se ha insertado el usuario {reg.nombreUsuario}");
                }
                catch (SqlException ex)
                {
                    return (false, ex.Message);
                }
                finally
                {
                    await cn.CloseAsync();
                }
            }
        }


        // Buscar usuario por id
        private async Task<Usuario?> buscar(int id)
        {
            var usuarios = await listarUsuarios();
            return usuarios.FirstOrDefault(u => u.idUsuario == id);
        }

        // Editar usuario
        private async Task<(bool exito, string mensaje)> EditarUsuario(Usuario reg)
        {
            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_EditarUsuario", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdUsuario", reg.idUsuario);
                    cmd.Parameters.AddWithValue("@Codigo", reg.codigoUsuario);
                    cmd.Parameters.AddWithValue("@Nombre", reg.nombreUsuario);
                    cmd.Parameters.AddWithValue("@Apellido", reg.apellidoUsuario);
                    cmd.Parameters.AddWithValue("@Email", reg.email);
                    cmd.Parameters.AddWithValue("@Telefono", reg.telefono);
                    cmd.Parameters.AddWithValue("@Contrasena", reg.contrasena);
                    cmd.Parameters.AddWithValue("@Rol", reg.idRol);
                    cmd.Parameters.AddWithValue("@Activo", reg.Activo);

                    await cn.OpenAsync();
                    await cmd.ExecuteNonQueryAsync();
                    return (true, $"Se ha actualizado el usuario {reg.nombreUsuario}");
                }
                catch (SqlException ex)
                {
                    return (false, ex.Message);
                }
                finally
                {
                    await cn.CloseAsync();
                }
            }
        }


        public async Task<IActionResult> ListUsuario()
        {
            var usuarios = await listarUsuarios();
            return View(usuarios);
        }

        // GET: Create
        [HttpGet]
        public async Task<IActionResult> Create()
        {
            var roles = await listarRol();
            ViewBag.rol = new SelectList(roles, "idRol", "nombreRol");
            return View(new Usuario());
        }

        // POST: Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Usuario reg)
        {
            if (!ModelState.IsValid)
            {
                var roles = await listarRol();
                ViewBag.rol = new SelectList(roles, "idRol", "nombreRol", reg.idRol);
                return View(reg);
            }

            var (exito, mensaje) = await NuevoUsuario(reg);

            if (exito)
            {
                TempData["Success"] = mensaje;
                return RedirectToAction("ListUsuario");
            }
            else
            {
                TempData["Error"] = mensaje;
                var roles = await listarRol();
                ViewBag.rol = new SelectList(roles, "idRol", "nombreRol", reg.idRol);
                return View(reg);
            }
        }


        // GET: Edit
        [HttpGet]
        public async Task<IActionResult> Edit(int? id = null)
        {
            if (id == null)
                return RedirectToAction(nameof(ListUsuario));

            var reg = await buscar(id.Value);
            if (reg == null)
                return NotFound();

            var roles = await listarRol();
            ViewBag.rol = new SelectList(roles, "idRol", "nombreRol", reg.idRol);
            return View(reg);
        }

        // POST: Edit
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Usuario reg)
        {
            if (!ModelState.IsValid)
            {
                var roles = await listarRol();
                ViewBag.rol = new SelectList(roles, "idRol", "nombreRol", reg.idRol);
                return View(reg);
            }

            var (exito, mensaje) = await EditarUsuario(reg);

            if (exito)
            {
                TempData["Success"] = mensaje;
                return RedirectToAction("ListUsuario");
            }
            else
            {
                TempData["Error"] = mensaje;
                var roles = await listarRol();
                ViewBag.rol = new SelectList(roles, "idRol", "nombreRol", reg.idRol);
                return View(reg);
            }
        }

        // GET: Details
        [HttpGet]
        public async Task<IActionResult> Details(int? id = null)
        {
            if (id == null)
                return RedirectToAction(nameof(ListUsuario));

            var usuario = await buscar(id.Value);
            if (usuario == null)
                return NotFound();

            return View(usuario);
        }

        [HttpPost]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            bool exito = false;
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(_config["ConnectionStrings:sql"]))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_EliminarUsuario", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdUsuario", id);

                    await cn.OpenAsync();
                    await cmd.ExecuteNonQueryAsync();
                    exito = true;
                    mensaje = $"Se ha eliminado el usuario con Id {id}";
                }
                catch (SqlException ex)
                {
                    mensaje = ex.Message;
                }
                finally
                {
                    await cn.CloseAsync();
                }
            }

            return Json(new { exito, mensaje });
        }
    }
}
