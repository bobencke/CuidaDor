using CuidaDor.Application.Interfaces;
using CuidaDor.Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace CuidaDor.Application
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddApplication(this IServiceCollection services)
        {
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<IUserService, UserService>();
            services.AddScoped<IPainAssessmentService, PainAssessmentService>();
            services.AddScoped<IReliefTechniqueService, ReliefTechniqueService>();
            services.AddScoped<IReportService, ReportService>();
            services.AddScoped<IFeedbackService, FeedbackService>();

            return services;
        }
    }
}
